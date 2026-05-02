# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

# 1. MOVE THE 'let' BLOCK HERE (Before the '{' or right after the function arguments)
let
    pulse-cookie = pkgs.python3.pkgs.buildPythonApplication rec {
    pname = "pulse-cookie";
    version = "1.0";
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-ZURSXfChq2k8ktKO6nc6AuVaAMS3eOcFkiKahpq4ebU=";
    };

    pyproject = true;
    # Add setuptools-scm to this list
    nativeBuildInputs = with pkgs.python3.pkgs; [
      setuptools
      setuptools-scm
      wheel
    ];

    propagatedBuildInputs = with pkgs.python3.pkgs; [
      pyqt6
      pyqt6-webengine
    ];
    doCheck = false;
  };

  codexLatest = pkgs.writeShellScriptBin "codex" ''
    exec ${pkgs.nix}/bin/nix run --refresh github:sadjow/codex-cli-nix -- "$@"
  '';

  zedNvidia = pkgs.writeShellScriptBin "zedn" ''
    exec nvidia-offload ${lib.getExe pkgs.zed-editor} "$@"
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

     # add custom modules:
     # ./vendor/modules/my-service.nix
     # ./vendor/modules/hyprland.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Prefer the default kernel package set for better NVIDIA module compatibility.
  boot.kernelPackages = pkgs.linuxPackages;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openconnect
  ];

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  # Per-project development environments.
  programs.direnv.enable = true;

  # Allow Zed's downloaded Codex ACP binary to run on NixOS.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libcap
      openssl
      zlib
    ];
  };

  # Use the classic D-Bus daemon; dbus-broker can fail during rebuild switches.
  services.dbus.implementation = lib.mkForce "dbus";

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.panks = {
    isNormalUser = true;
    description = "panks";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = false;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  security.pam.services.hyprlock = {};
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General.FastConnectable = true;
      Policy = {
        ReconnectAttempts = 12;
        ReconnectIntervals = "1,2,4,8,16,32,64";
      };
    };
    input.General.ClassicBondedOnly = false;
  };
  services.blueman.enable = true;

  services.kanata = {
    enable = true;
    keyboards.apple-style.configFile = ./kanata-apple-magic-uk.kbd;
  };

  # Remote desktop/game streaming host for Moonlight clients.
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # Required for Wayland/DRM capture.
    openFirewall = true;
  };

  # Nota: questa opzione seleziona anche il driver kernel/userspace su NixOS;
  # non abilita Xorg da sola (services.xserver.enable resta false).
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA PRIME offload (on-demand) for Wayland/Hyprland
  hardware.graphics.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     kitty
     firefox
     git
     tree
     jq
     htop
     openconnect
     pulse-cookie  # This now refers to the variable defined above
     networkmanagerapplet
     zed-editor
     zedNvidia
     cudaPackages.cudatoolkit
     codexLatest
  ];

  # nvcc from cuda_nvcc needs explicit include/lib paths on this split CUDA layout.
  environment.variables.NVCC_PREPEND_FLAGS =
    "-I${pkgs.cudaPackages.cudatoolkit}/include -L${pkgs.cudaPackages.cudatoolkit}/lib";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
