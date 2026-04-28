# Hyprland keybindings

Source: `home.nix` (`wayland.windowManager.hyprland.settings`).

| Keys | Action |
|---|---|
| `SUPER + RETURN` | Open terminal (`kitty`) |
| `SUPER + D` | Open app launcher (`rofi -show drun`) |
| `SUPER + TAB` | Switch windows (`hypr-window-switch`) |
| `ALT + TAB` | Switch to previously focused window |
| `SUPER + Q` | Close active window |
| `SUPER + SHIFT + E` | Exit Hyprland |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + H / J / K / L` | Move focus left/down/up/right |
| `SUPER + Arrow keys` | Move focus left/down/up/right |
| `SUPER + 1..9` | Switch to workspace 1..9 |
| `SUPER + SHIFT + 1..9` | Move active window to workspace 1..9 |
| `SUPER + SHIFT + V` | Clipboard history picker (`cliphist` + `rofi`) |
| `Print` | Area screenshot to clipboard (`grim` + `slurp`) |
| `SHIFT + Print` | Full screenshot to clipboard (`grim`) |
| `XF86AudioRaiseVolume` | Volume +5% (`pamixer -i 5`) |
| `XF86AudioLowerVolume` | Volume -5% (`pamixer -d 5`) |
| `XF86AudioMute` | Toggle mute (`pamixer -t`) |
| `XF86MonBrightnessUp` | Brightness +10% |
| `XF86MonBrightnessDown` | Brightness -10% |
| `SUPER + CTRL + H / J / K / L` | Resize active window (left/down/up/right) |
| `SUPER + CTRL + Arrow keys` | Resize active window (left/down/up/right) |
| `SUPER + Mouse Left` | Move window |
| `SUPER + Mouse Right` | Resize window |

## Notes
- `SUPER` is the `$mod` key in `home.nix`.
- Media/brightness keys depend on keyboard support and the corresponding packages.
