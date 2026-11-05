{
  flake.modules.nixos.nvidia =
    { pkgs, ... }:
    {
      # Loads the driver; also needed on Wayland-only systems.
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        # The open kernel module needs a Turing (RTX 20 / GTX 16) or newer GPU.
        open = true;
        # Saves video memory across suspend, avoiding corrupted windows on resume.
        powerManagement.enable = true;
      };

      # Hardware video decoding through VA-API.
      hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        NVD_BACKEND = "direct";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    };
}
