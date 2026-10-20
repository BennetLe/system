final: prev: {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pyfinal: pyprev: {
        deal = pyprev.deal.overridePythonAttrs (old: {
          disabledTestPaths =
            (old.disabledTestPaths or [])
            ++ [
              "tests/test_linter/test_extractors/test_exceptions.py"
            ];
        });
        # newer pygments escapes quotes as &quot;, breaking the HTML snapshot tests
        diff-cover = pyprev.diff-cover.overridePythonAttrs (old: {
          disabledTests =
            (old.disabledTests or [])
            ++ [
              "test_added_file_pycodestyle_html"
              "test_all_reports"
              "test_added_file_pyflakes_html"
              "test_added_file_pylint_html"
              "test_fail_under_html"
              "test_fail_under_pass_html"
            ];
        });
      })
    ];
}
