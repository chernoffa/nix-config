{ inputs, ... }:

{
  flake.modules.homeManager.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.nix-index-database.homeModules.nix-index
      ];
      home.packages = [
        pkgs.dig.dnsutils
        pkgs.moreutils
        pkgs.fd
        pkgs.file
        pkgs.httpie
        pkgs.wget
        pkgs.unzip
        pkgs.tre-command
      ];
      # Syntax-highlighted man pages.
      home.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };
      programs = {
        bat = {
          enable = true;
          # Picked by the terminal's background color.
          config = {
            theme-dark = "Catppuccin Mocha";
            theme-light = "Catppuccin Latte";
          };
        };
        btop = {
          enable = true;
          # Use the terminal's palette, so it follows light/dark.
          settings = {
            color_theme = "TTY";
            theme_background = false;
          };
        };
        direnv = {
          enable = true;
          nix-direnv = {
            enable = true;
            package = lib.mkIf (config.nix.package != null) (
              pkgs.nix-direnv.override { nix = config.nix.package; }
            );
          };
        };
        eza = {
          enable = true;
          enableZshIntegration = true;
        };
        fzf = {
          enable = true;
          enableZshIntegration = true;
        };
        jq.enable = true;
        less.enable = true;
        ripgrep.enable = true;
        starship = {
          enable = false;
          settings = {
            custom.jj = {
              command = ''
                jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
                  separate(" ",
                    change_id.shortest(4),
                    bookmarks,
                    "|",
                    concat(
                      if(conflict, "conflict"),
                      if(divergent, "divergent"),
                      if(hidden, "hidden"),
                      if(immutable, "immutable"),
                    ),
                    raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
                    raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                      truncate_end(29, description.first_line(), "..."),
                      "(no description set)",
                    ) ++ raw_escape_sequence("\x1b[0m"),
                  )
                '
              '';
              ignore_timeout = true;
              description = "The current jj status";
              detect_folders = [ ".jj" ];
              symbol = "jj ";
            };
          };
        };
        zoxide = {
          enable = true;
          enableZshIntegration = true;
        };
      };
    };
}
