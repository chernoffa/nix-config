{ flake, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    extraPackages = [
      pkgs.nixd
      pkgs.nixfmt
    ];
    settings = {
      editor = {
        auto-save = true;
        cursorline = true;
        gutters = [
          "diagnostics"
          "line-numbers"
        ];
        line-number = "relative";
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
          display-signature-help-docs = true;
        };
        soft-wrap.enable = true;
        true-color = true;
      };
      theme = "zed_onelight";
    };
    languages = {
      language-server.nixd = {
        command = "nixd";
        # as of nixos 24.05, <nixpkgs> should be set to the flake used to
        # build the system
        config.nixpkgs.expr = "import <nixpkgs> {}";
      };
      language = [
        {
          name = "haskell";
          roots = [
            "Setup.hs"
            "stack.yaml"
            "*.cabal"
          ];
          auto-format = true;
        }
        {
          name = "nix";
          file-types = [ "nix" ];
          formatter = {
            command = "nixfmt";
          };
          auto-format = true;
          language-servers = [ "nixd" ];
        }
      ];
    };
  };
}
