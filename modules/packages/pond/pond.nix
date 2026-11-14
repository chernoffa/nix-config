{
  # Pond's desktop (github.com/bflycomputer/pond-interface), split into the
  # same packages as pond-pkgbuilds/pond-interface.
  flake.overlays.pond = final: _: {
    pond = final.lib.makeScope final.newScope (self: {
      version = "0-unstable-2026-11-13";
      src = final.fetchFromGitHub {
        owner = "bflycomputer";
        repo = "pond-interface";
        rev = "45c91234a5644e6832df65531f67569e029c8d5b";
        hash = "sha256-Lv3z29sEz2PATky98YZBs3G1wYXpSR3da7FD6LWa9/Y=";
      };

      pythonEnv = self.callPackage ./_python.nix { };
      wallpaper = self.callPackage ./_wallpaper.nix { };
      screenshot = self.callPackage ./_screenshot.nix { };
      lockscreen = self.callPackage ./_lockscreen.nix { };
      shell = self.callPackage ./_shell.nix { };

      inherit (self.callPackage ./_fonts.nix { }) onest advent-pro;
    });
  };

  perSystem =
    { pkgs, lib, ... }:
    {
      packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        pond-shell = pkgs.pond.shell;
        pond-lockscreen = pkgs.pond.lockscreen;
        pond-screenshot = pkgs.pond.screenshot;
        pond-wallpaper = pkgs.pond.wallpaper;
      };
    };
}
