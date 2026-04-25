# Kanata Apple Keyboard

This system uses Kanata to make the Apple keyboard modifier keys feel closer to
macOS while running NixOS/Hyprland.

Configuration source: `configuration.nix`, under `services.kanata`.

## Current mapping

| Physical key | Output key |
|---|---|
| Control | Super |
| Command | Control |
| Right Command | Right Control |
| Option | Alt, unchanged |

This means common macOS muscle-memory shortcuts like `Cmd+C`, `Cmd+V`,
`Cmd+A`, and `Cmd+S` are sent to Linux applications as `Ctrl+C`, `Ctrl+V`,
`Ctrl+A`, and `Ctrl+S`.

Hyprland shortcuts that use `SUPER` move to the physical `Control` key because
Kanata remaps physical `Control` to `Super`.

## Apply changes

After editing the Kanata config:

```bash
nix flake check
sudo nixos-rebuild switch --flake .#nixos
```

## Enable and disable

Stop Kanata temporarily:

```bash
sudo systemctl stop kanata-apple-style
```

Start it again:

```bash
sudo systemctl start kanata-apple-style
```

Check status:

```bash
systemctl status kanata-apple-style
```

Read logs from the current boot:

```bash
journalctl -u kanata-apple-style -b
```

Disable Kanata persistently by changing this in `configuration.nix`:

```nix
services.kanata.enable = false;
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## Recovery

If the keyboard mapping feels unusable, stop Kanata:

```bash
sudo systemctl stop kanata-apple-style
```

If needed, use the laptop keyboard, a USB keyboard, or switch to a TTY first.
