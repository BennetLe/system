{pkgs, ...}: {
  environment = {
    # Helix + LSP Server
    systemPackages = with pkgs; [
      helix
      python312Packages.python-lsp-server
      lldb
      zls
      yaml-language-server
      tombi
      templ
      asm-lsp
      marksman
      texlab
      vscode-json-languageserver
      superhtml
      jq-lsp
      gopls
      docker-language-server
      clang_21
      llvmPackages_21.clang-unwrapped
      cmake-language-server
      kdePackages.qtdeclarative # QuickShell / QML LSP
    ];
  };
}
