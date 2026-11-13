{ inputs, ... }:

let
  helixFor = pkgs: inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ (helixFor pkgs) ];
    };

  flake.modules.darwin.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ (helixFor pkgs) ];
      environment.variables.EDITOR = "hx";
    };

  flake.modules.homeManager.base =
    { pkgs, ... }:

    {
      programs.helix = {
        enable = true;
        package = helixFor pkgs;
        defaultEditor = true;
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
          # Follows the terminal's light/dark mode (mode 2031); needs the
          # unreleased helix from the flake input.
          theme = {
            light = "zed_onelight";
            dark = "zed_onedark";
          };
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
    };
}
