#!/usr/bin/env python3
"""Compare the current flake.lock with a freshly updated one and publish the
result as a Gitea issue (label `flake-status`).

Env:
  GH_TOKEN            GitHub token, only used read-only for the compare API and
                      nix fetches of upstream inputs; never sent to Gitea
  GITEA_API           e.g. https://git.example.com/api/v1 (the issue lives here)
  REPO                owner/repo on Gitea
  FLAKE_STATUS_TOKEN  Gitea token (falls back to GITEA_TOKEN)
  SHA                 commit the report is based on (optional)
  DRY_RUN=1           print the markdown instead of touching Gitea
"""

import datetime as dt
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request

HOSTS = ["bennet", "framework"]
LABEL = "flake-status"
TITLE = "Flake input status"
MAX_LIST = 300
MAX_EXCLUDE_RETRIES = 30

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HELPER = os.path.join(REPO_ROOT, "ci", "flake-report.nix")
GH_TOKEN = os.environ.get("GH_TOKEN", "").strip()


def log(msg):
    print(msg, file=sys.stderr, flush=True)


def nix_opts():
    return ["--option", "access-tokens", f"github.com={GH_TOKEN}"] if GH_TOKEN else []


def copy_flake(dst):
    """Copy the git-tracked files, like a `git+file:` flake would see them."""
    files = subprocess.run(
        ["git", "-C", REPO_ROOT, "ls-files", "-z"], capture_output=True, text=True, check=True
    ).stdout.split("\0")
    for f in filter(None, files):
        src, target = os.path.join(REPO_ROOT, f), os.path.join(dst, f)
        if os.path.lexists(src):
            os.makedirs(os.path.dirname(target), exist_ok=True)
            shutil.copy2(src, target, follow_symlinks=False)


# --- inputs ------------------------------------------------------------------


def http_json(url, headers=None, method="GET", data=None):
    body = json.dumps(data).encode() if data is not None else None
    req = urllib.request.Request(url, data=body, method=method, headers=headers or {})
    if body is not None:
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def commits_behind(owner, repo, old, new):
    if old == new:
        return 0
    headers = {"Accept": "application/vnd.github+json"}
    if GH_TOKEN:
        headers["Authorization"] = f"Bearer {GH_TOKEN}"
    url = f"https://api.github.com/repos/{owner}/{repo}/compare/{old}...{new}"
    try:
        return http_json(url, headers)["ahead_by"]
    except (urllib.error.URLError, KeyError, ValueError) as e:
        log(f"compare {owner}/{repo} failed: {e}")
        return None


def input_rows(old_lock, new_lock):
    now = dt.datetime.now(dt.timezone.utc)
    rows = []
    for name, node_name in old_lock["nodes"]["root"]["inputs"].items():
        if not isinstance(node_name, str):  # `follows`
            continue
        old = old_lock["nodes"][node_name]
        new = new_lock["nodes"].get(new_lock["nodes"]["root"]["inputs"].get(name), {})
        locked, original = old.get("locked", {}), old.get("original", {})
        age = now - dt.datetime.fromtimestamp(locked.get("lastModified", 0), dt.timezone.utc)
        behind = None
        if locked.get("type") == "github" and new.get("locked", {}).get("rev"):
            behind = commits_behind(
                locked["owner"], locked["repo"], locked["rev"], new["locked"]["rev"]
            )
        rows.append(
            {
                "name": name,
                "ref": original.get("ref", "default"),
                "rev": locked.get("rev", "")[:7],
                "age": age.days,
                "behind": behind,
                "url": f"https://github.com/{locked.get('owner')}/{locked.get('repo')}"
                if locked.get("type") == "github"
                else None,
            }
        )
    return rows


# --- evaluation --------------------------------------------------------------

OPTION_RE = re.compile(r"flake-report: option `([^']*)'")


STORE_SRC_RE = re.compile(r"/nix/store/[a-z0-9]{32}-source/?")


def nix_str(s):
    return json.dumps(s).replace("${", "\\${")


def evaluate(flake_dir, host, exclude):
    """Returns (report, None) or (None, error text).

    `exclude` is shared between calls and grows as unevaluable options are
    found, so later evaluations don't have to rediscover them."""
    for _ in range(MAX_EXCLUDE_RETRIES):
        expr = (
            f"import {HELPER} {{ flakePath = {nix_str('path:' + flake_dir)}; "
            f"host = {nix_str(host)}; exclude = [ {' '.join(map(nix_str, exclude))} ]; }}"
        )
        p = subprocess.run(
            ["nix", "eval", "--json", "--impure", *nix_opts(), "--expr", expr],
            capture_output=True,
            text=True,
        )
        if p.returncode == 0:
            report = json.loads(p.stdout)
            report["excluded"] = list(exclude)
            # store paths differ between the two copies; keep messages comparable
            for k in ("warnings", "failedAssertions"):
                report[k] = [STORE_SRC_RE.sub("./", w).strip() for w in report[k]]
            return report, None
        # An option whose value can't be evaluated (and is never forced by the
        # real build) aborts the whole eval: skip it and retry.
        m = OPTION_RE.search(p.stderr)
        if m and m.group(1) not in exclude:
            log(f"[{host}] skipping unevaluable option {m.group(1)}")
            exclude.append(m.group(1))
            continue
        return None, "\n".join(p.stderr.strip().splitlines()[-15:])
    return None, f"gave up after skipping {len(exclude)} options"


def diff(old, new):
    """Set of hashable change tuples for one host."""
    changes = set()
    op, np_ = old["packages"], new["packages"]
    for n in op.keys() | np_.keys():
        if n not in np_:
            changes.add(("pkg-removed", n, op[n]))
        elif n not in op:
            changes.add(("pkg-added", n, np_[n]))
        elif op[n] != np_[n]:
            changes.add(("pkg-updated", n, op[n], np_[n]))
    skipped = set(old["excluded"]) | set(new["excluded"])
    oo, no = old["options"], new["options"]
    for o in oo.keys() - skipped:
        if o not in no:
            changes.add(("opt-removed", o))
        elif oo[o] != no[o]:
            changes.add(("opt-changed", o))
    for w in set(new["warnings"]) - set(old["warnings"]):
        changes.add(("warning", w))
    for a in set(new["failedAssertions"]) - set(old["failedAssertions"]):
        changes.add(("assertion", a))
    return changes


# --- rendering ---------------------------------------------------------------

KINDS = [
    ("pkg-updated", "Packages updated"),
    ("pkg-added", "Packages added"),
    ("pkg-removed", "Packages removed"),
    ("opt-changed", "Options changed"),
    ("opt-removed", "Options removed / renamed"),
    ("warning", "New warnings"),
    ("assertion", "New failed assertions"),
]


def fmt_change(c):
    kind = c[0]
    if kind == "pkg-updated":
        return f"`{c[1]}` {c[2]} → {c[3]}"
    if kind == "pkg-added":
        return f"`{c[1]}` {c[2]}"
    if kind == "pkg-removed":
        return f"`{c[1]}` {c[2]}"
    if kind in ("opt-changed", "opt-removed"):
        return f"`{c[1]}`"
    return c[1].replace("\n", " ")


def render_details(title, changes):
    if not changes:
        return ""
    out = [f"<details><summary><b>{title}</b> ({len(changes)} changes)</summary>\n"]
    for kind, label in KINDS:
        items = sorted(fmt_change(c) for c in changes if c[0] == kind)
        if not items:
            continue
        out.append(f"\n**{label}**\n")
        out += [f"- {i}" for i in items[:MAX_LIST]]
        if len(items) > MAX_LIST:
            out.append(f"- … and {len(items) - MAX_LIST} more")
    out.append("\n</details>\n")
    return "\n".join(out)


def render(rows, columns, errors, sha):
    now = dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    md = [f"# {TITLE}", ""]
    md.append(f"_Updated {now}" + (f" · lock from `{sha[:10]}`" if sha else "") + "_")
    md += ["", "| Input | Branch | Locked | Age | Behind |", "|---|---|---|---|---|"]
    for r in sorted(rows, key=lambda r: -(r["behind"] or 0)):
        name = f"[{r['name']}]({r['url']})" if r["url"] else r["name"]
        behind = "n/a" if r["behind"] is None else ("✅ up to date" if r["behind"] == 0 else f"{r['behind']} commits")
        md.append(f"| {name} | `{r['ref']}` | `{r['rev']}` | {r['age']} d | {behind} |")

    md += ["", "## Impact of `nix flake update`", ""]
    names = list(columns)
    md.append("| | " + " | ".join(n.capitalize() if n == "shared" else f"`{n}`" for n in names) + " |")
    md.append("|---" * (len(names) + 1) + "|")
    for kind, label in KINDS:
        cells = []
        for n in names:
            ch = columns[n]
            cells.append("❌" if ch is None else str(sum(1 for c in ch if c[0] == kind)))
        md.append(f"| {label} | " + " | ".join(cells) + " |")
    md.append("")
    for n in names:
        if columns[n]:
            md.append(render_details(n.capitalize() if n == "shared" else n, columns[n]))
    for host, err in errors.items():
        md += [f"<details><summary>❌ <b>{host}</b> evaluation failed</summary>\n", "```", err, "```", "</details>", ""]
    md.append("<sub>Packages: system, font, user and home-manager packages. "
              "Options: NixOS options set in this repo whose value changes. "
              "Generated by `ci/flake-report.py`.</sub>")
    return "\n".join(md)


# --- gitea -------------------------------------------------------------------


def publish(body):
    api = os.environ["GITEA_API"].rstrip("/")
    repo = os.environ["REPO"]
    token = os.environ.get("FLAKE_STATUS_TOKEN") or os.environ["GITEA_TOKEN"]
    host = urllib.parse.urlparse(api).hostname or ""
    if host == "github.com" or host.endswith(".github.com"):
        sys.exit(f"refusing to publish: GITEA_API points at GitHub ({api})")
    if GH_TOKEN and token == GH_TOKEN:
        sys.exit("refusing to publish: the GitHub token must not be used for Gitea")
    h = {"Authorization": f"token {token}", "Accept": "application/json"}

    labels = http_json(f"{api}/repos/{repo}/labels?limit=100", h)
    label = next((l for l in labels if l["name"] == LABEL), None)
    if label is None:
        label = http_json(f"{api}/repos/{repo}/labels", h, "POST", {"name": LABEL, "color": "#5277c3"})

    q = urllib.parse.urlencode({"state": "open", "type": "issues", "labels": LABEL})
    issues = http_json(f"{api}/repos/{repo}/issues?{q}", h)
    if issues:
        n = issues[0]["number"]
        http_json(f"{api}/repos/{repo}/issues/{n}", h, "PATCH", {"body": body})
        log(f"updated issue #{n}")
    else:
        i = http_json(f"{api}/repos/{repo}/issues", h, "POST",
                      {"title": TITLE, "body": body, "labels": [label["id"]]})
        log(f"created issue #{i['number']}")


# --- main --------------------------------------------------------------------


def main():
    if not GH_TOKEN:
        log("warning: GH_TOKEN not set, GitHub API calls are rate limited")

    with tempfile.TemporaryDirectory(dir=os.environ.get("RUNNER_TEMP")) as tmp:
        cur, upd = os.path.join(tmp, "current"), os.path.join(tmp, "updated")
        copy_flake(cur)
        copy_flake(upd)
        log("updating flake inputs …")
        subprocess.run(["nix", "flake", "update", *nix_opts(), "--flake", f"path:{upd}"], check=True)

        with open(os.path.join(cur, "flake.lock")) as f:
            old_lock = json.load(f)
        with open(os.path.join(upd, "flake.lock")) as f:
            new_lock = json.load(f)
        rows = input_rows(old_lock, new_lock)

        per_host, errors, exclude = {}, {}, []
        for host in HOSTS:
            log(f"[{host}] evaluating current lock …")
            old, err_old = evaluate(cur, host, exclude)
            log(f"[{host}] evaluating updated lock …")
            new, err_new = evaluate(upd, host, exclude)
            if old and new:
                per_host[host] = diff(old, new)
            else:
                per_host[host] = None
                errors[host] = (f"current lock:\n{err_old}\n" if err_old else "") + (
                    f"updated lock:\n{err_new}" if err_new else ""
                )

    ok = [h for h in HOSTS if per_host[h] is not None]
    shared = set.intersection(*(per_host[h] for h in ok)) if len(ok) == len(HOSTS) else None
    columns = {"shared": shared}
    for h in HOSTS:
        columns[h] = None if per_host[h] is None else per_host[h] - (shared or set())

    body = render(rows, columns, errors, os.environ.get("SHA", ""))
    if os.environ.get("DRY_RUN"):
        print(body)
    else:
        publish(body)


if __name__ == "__main__":
    main()
