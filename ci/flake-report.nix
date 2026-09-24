# Evaluates one host of a flake and returns a JSON-friendly summary used by
# ci/flake-report.py to diff the current lock against an updated one.
#
#   nix eval --json --impure --expr \
#     'import ./ci/flake-report.nix { flakePath = "path:/abs/dir"; host = "bennet"; }'
#
# `exclude` lists option paths whose value cannot be evaluated at all (errors
# tryEval cannot catch); the Python side fills it in and retries.
{
  flakePath,
  host,
  exclude ? [],
}: let
  flake = builtins.getFlake flakePath;
  cfg = flake.nixosConfigurations.${host};
  inherit (cfg) config options;
  lib = flake.inputs.nixpkgs.lib;
  src = toString flake.outPath;

  # --- packages --------------------------------------------------------------
  hmUsers = builtins.attrValues (config.home-manager.users or {});
  allPackages =
    config.environment.systemPackages
    ++ config.fonts.packages
    ++ lib.concatMap (u: u.packages) (builtins.attrValues config.users.users)
    ++ lib.concatMap (u: u.home.packages) hmUsers;

  pkgInfo = p: let
    info = let
      parsed = builtins.parseDrvName (p.name or "");
    in {
      name = p.pname or parsed.name;
      version = p.version or parsed.version;
    };
    r = builtins.tryEval (builtins.deepSeq info info);
  in
    if r.success && r.value.name != ""
    then [r.value]
    else [];

  # name -> "v1, v2" (a package can be installed in several versions)
  packages =
    lib.mapAttrs
    (_: ps: lib.concatStringsSep ", " (lib.unique (lib.sort (a: b: a < b) (map (p: p.version) ps))))
    (lib.groupBy (p: p.name) (lib.concatMap pkgInfo allPackages));

  # --- options ---------------------------------------------------------------
  # Turn an option value into something toJSON can always handle. tryEval only
  # catches throw/assert, so functions, derivations and huge sets are replaced
  # by markers instead of being serialised.
  safe = depth: x: let
    r = builtins.tryEval x;
  in
    if r.success
    then sanitize depth r.value
    else "<error>";
  sanitize = depth: v: let
    t = builtins.typeOf v;
  in
    if depth > 6
    then "<deep>"
    else if lib.isDerivation v
    then "<drv:${v.name or "?"}>"
    else if t == "lambda"
    then "<function>"
    else if t == "path"
    then toString v
    else if t == "set"
    then
      if builtins.length (builtins.attrNames v) > 200
      then "<large set>"
      else builtins.mapAttrs (_: safe (depth + 1)) v
    else if t == "list"
    then map (safe (depth + 1)) v
    else v;

  hash = v: builtins.hashString "sha256" (builtins.unsafeDiscardStringContext (builtins.toJSON v));

  isOwn = opt:
    builtins.any (d: lib.hasPrefix src (toString d.file)) (opt.definitionsWithLocations or []);

  # home-manager.users holds whole HM configurations; too big to hash as one value.
  skipped = ["home-manager.users" "_module.args"] ++ exclude;

  # The context marker lets ci/flake-report.py find which option broke the
  # eval (e.g. an unforced `mkIf` condition) and add it to `exclude`.
  withOption = opt: builtins.addErrorContext "flake-report: option `${lib.showOption opt.loc}'";

  ownOptions =
    builtins.filter
    (opt:
      !(builtins.elem (lib.showOption opt.loc) skipped)
      && withOption opt (let r = builtins.tryEval (isOwn opt); in r.success && r.value))
    (lib.collect lib.isOption options);

  optionHashes = builtins.listToAttrs (map (opt: {
      name = lib.showOption opt.loc;
      value = withOption opt (hash (safe 0 opt.value));
    })
    ownOptions);
in {
  inherit packages;
  options = optionHashes;
  warnings = config.warnings;
  failedAssertions = map (a: a.message) (builtins.filter (a: !a.assertion) config.assertions);
}
