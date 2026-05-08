# NixOS Flake Configuration

A reproducible NixOS desktop configuration built with flakes and Home Manager.
The setup is focused on a macOS-style input experience on Linux: Apple Magic
Keyboard and Apple Magic Trackpad support, Kanata-based key remapping, and a
Hyprland desktop that can be used locally or remotely from macOS through
Moonlight and Sunshine.

This repository is intended to be used as a complete `/etc/nixos` configuration
or as a reference for building a NixOS workstation that feels natural to use
from Apple hardware.

## Design Goals

- Make Apple Magic Keyboard shortcuts behave like macOS muscle memory while
  running Linux applications.
- Keep the Apple Magic Trackpad usable as a first-class pointing device in a
  Wayland desktop session.
- Expose the full desktop over Sunshine so it can be controlled from a macOS
  machine with Moonlight.
- Preserve macOS-native keyboard expectations when connecting remotely from
  Moonlight, so common shortcuts keep the same physical feel across local and
  remote use.
- Keep the system reproducible and easy to rebuild with Nix flakes.

## Features

- Nix flakes-based system configuration
- Home Manager integration
- Hyprland desktop session
- NVIDIA PRIME offload helpers
- Bluetooth support for Apple input devices
- Kanata keyboard remapping for macOS-style modifier behavior
- Apple Magic Trackpad-oriented desktop input settings
- Sunshine host configuration for full-desktop Moonlight streaming
- Moonlight/Sunshine workflow suitable for remote use from macOS
- NetworkManager support
- Local helper scripts for NixOS option and package lookup

## Repository Layout

```text
.
├── flake.nix                     # Flake inputs and NixOS host output
├── flake.lock                    # Locked input revisions
├── configuration.nix             # System configuration
├── home.nix                      # Home Manager user configuration
├── hardware-configuration.nix    # Machine-specific hardware configuration
├── kanata-apple-magic-uk.kbd     # Kanata keyboard mapping
├── docs/                         # Notes and operational documentation
├── scripts/                      # Maintenance and reference helpers
└── vendor/nixpkgs                # Optional local nixpkgs source checkout
```

## Prerequisites

- NixOS
- Git
- Ability to run Nix flake commands
- A target-machine review before switching

The original NixOS installation does not need flakes enabled permanently before
using this repository. Flakes are enabled by this configuration after the first
successful switch. For the first `nix flake check` or `nixos-rebuild --flake`,
either enable flakes in the current system or pass the temporary flags:

```sh
nix --extra-experimental-features "nix-command flakes" flake check
sudo nixos-rebuild --option experimental-features "nix-command flakes" build --flake .#nixos
```

## Configure for the Target Machine

This configuration contains hardware and user-specific values that must be
reviewed before switching on a new machine.

Generate a fresh hardware configuration on the target system:

```sh
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

Set the host name in `configuration.nix`:

```nix
networking.hostName = "nixos";
```

Change `"nixos"` to the desired host name:

```nix
networking.hostName = "workstation";
```

Search for the following assignments and update them for the target machine.
Set the system user in `configuration.nix`:

```nix
users.users.olduser = {
  isNormalUser = true;
  description = "olduser";
  extraGroups = [ "networkmanager" "wheel" "video" "input" "uinput" ];
};
```

Change the attribute name and description to the target username:

```nix
users.users.newuser = {
  isNormalUser = true;
  description = "newuser";
  extraGroups = [ "networkmanager" "wheel" "video" "input" "uinput" ];
};
```

Set the Home Manager user in `flake.nix`:

```nix
home-manager.users.olduser = import ./home.nix;
```

Change it to the same username used in `configuration.nix`:

```nix
home-manager.users.newuser = import ./home.nix;
```

Set the Home Manager account values in `home.nix`:

```nix
home.username = "olduser";
home.homeDirectory = "/home/olduser";
```

Change both values to match the target account:

```nix
home.username = "newuser";
home.homeDirectory = "/home/newuser";
```

Review NVIDIA PRIME bus IDs in `configuration.nix`:

```nix
hardware.nvidia.prime = {
  intelBusId = "PCI:0:2:0";
  nvidiaBusId = "PCI:1:0:0";
};
```

Find the target machine values with:

```sh
lspci | grep -E "VGA|3D|Display"
```

If the target machine does not use NVIDIA PRIME offload, remove or disable the
NVIDIA-specific settings before switching.

Review Hyprland monitor descriptors in `home.nix`:

```nix
monitor = [
  "desc:<internal-display>,preferred,auto,auto"
  "desc:<external-display>,preferred,auto-left,auto"
  ",preferred,auto,auto"
];
```

Replace them with descriptors from the target machine, or keep only the generic
fallback while testing:

```nix
monitor = [
  ",preferred,auto,auto"
];
```

Review the Kanata device filter in `kanata-apple-magic-uk.kbd`:

```scheme
linux-dev-names-include (
   "<apple-keyboard-device-name>"
   "<remote-keyboard-device-name>"
)
```

Replace those names with the target keyboard device names, or temporarily
comment out the filter while testing. Device names can be checked with:

```sh
grep -E '^(N: Name=|H: Handlers=)' /proc/bus/input/devices
```

Pair Apple Magic Keyboard and Apple Magic Trackpad before relying on the full
desktop workflow:

```sh
bluetoothctl
scan on
pair <device-mac>
trust <device-mac>
connect <device-mac>
```

Review Sunshine after the first successful switch. Pair Moonlight from the macOS
client and confirm that keyboard shortcuts behave as expected in the streamed
Hyprland session.

## Installation

Clone the repository:

```sh
git clone git@github.com:<github-user>/<repo-name>.git ~/nixos-config
cd ~/nixos-config
git submodule update --init --recursive
```

Back up the existing NixOS configuration:

```sh
sudo mkdir -p /etc/nixos.backup
sudo cp -a /etc/nixos/. /etc/nixos.backup/
```

Link this repository as `/etc/nixos`:

```sh
sudo rm -rf /etc/nixos
sudo ln -s "$HOME/nixos-config" /etc/nixos
```

Confirm the link:

```sh
ls -ld /etc/nixos
readlink -f /etc/nixos
```

## Verification

Check the flake before building or switching:

```sh
nix flake check
```

Build the system without activating it:

```sh
sudo nixos-rebuild build --flake .#nixos
```

Apply the configuration:

```sh
sudo nixos-rebuild switch --flake .#nixos
```

After `/etc/nixos` is linked, the same switch can be run from any directory:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

## Usage

Edit the configuration:

```sh
cd ~/nixos-config
$EDITOR configuration.nix
$EDITOR home.nix
```

Look up NixOS options with the local helper:

```sh
./scripts/nix-ref.sh option services.openssh.enable
```

Search for packages:

```sh
./scripts/nix-ref.sh search firefox
```

Inspect package metadata:

```sh
./scripts/nix-ref.sh meta firefox
```

Commit changes after a successful check and rebuild:

```sh
git status
git add .
git commit -m "Update NixOS configuration"
git push
```

## Updating Inputs

Update the pinned nixpkgs input and align the local nixpkgs checkout:

```sh
./scripts/update-nixpkgs.sh
```

Update all flake inputs:

```sh
./scripts/update-nixpkgs.sh --all
```

Always verify after updating:

```sh
nix flake check
```

## Rollback

If a switch causes problems, roll back to the previous generation:

```sh
sudo nixos-rebuild switch --rollback
```

The previous generation is also available from the NixOS boot menu.

To restore a backed-up `/etc/nixos` directory:

```sh
sudo rm /etc/nixos
sudo mv /etc/nixos.backup /etc/nixos
```

## Documentation

Additional notes are available in `docs/`:

- Hyprland keybindings
- Kanata keyboard behavior
- Development project workflow
- NixOS reference links
