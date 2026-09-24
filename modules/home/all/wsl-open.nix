{ pkgs, ... }:
{
  home.packages = [
    pkgs.wsl-open
    pkgs.xdg-utils.out
  ];

  home.sessionVariables = {
    BROWSER = "${pkgs.wsl-open}/bin/wsl-open";
  };
}
