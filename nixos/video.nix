{ inputs, config, pkgs, ... }:

{
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  services.xserver.videoDrivers = ["nvidia"];

  services.xserver.deviceSection = ''
    Option "AllowIndirectGLXProtocol" "true"
    Option "TripleBuffer" "true"
    Option "ModeValidation" "NoDFPNativeResolutionCheck"
    Option "AllowEmptyInitialConfiguration" "true"
    Option "PrimaryGPU" "true"
    Option "RenderAccel" "true"
    Option "AllowIndirectGLXProtocol" "true"
    Option "DRI" "3"
    Option "TripleBuffer" "true"
  '';

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = false;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

}
