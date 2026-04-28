{ pkgs, ... }:

{
  home.username = "panks";
  home.homeDirectory = "/home/panks";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    # Disable HM's systemd glue when launching Hyprland via UWSM on NixOS.
    systemd.enable = false;

    settings = {
      "$mod" = "SUPER";
      monitor = [
	    "desc:BOE 0x0C8E,preferred,auto,auto"
	    "desc:HP Inc. HP V24i 1CR02906ZG,preferred,auto-left,auto"
	    ",preferred,auto,auto"
      ];
      exec-once = [
        "polkit-gnome-authentication-agent-1"
        "blueman-applet"
        "nm-applet --indicator"
        "waybar"
      ];

      bind = [
        "$mod, RETURN, exec, kitty"
        "$mod, D, exec, rofi -show drun"
        "$mod, TAB, exec, hypr-window-switch"
        "$mod, Q, killactive,"
        "$mod SHIFT, E, exit,"
        "$mod, F, fullscreen,"
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, V, exec, cliphist list | rofi -dmenu -p Clipboard | cliphist decode | wl-copy"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFT, Print, exec, grim - | wl-copy"
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
      ];

      bi1nde = [
        "$mod CTRL, left, resizeactive, -40 0"
        "$mod CTRL, right, resizeactive, 40 0"
        "$mod CTRL, up, resizeactive, 0 -40"
        "$mod CTRL, down, resizeactive, 0 40"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgb(89b4fa)";
        "col.inactive_border" = "rgb(313244)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
      };

      animations = {
        enabled = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
    };
  };

  programs.waybar = {
    enable = true;
    # Launch from Hyprland session for reliable startup with UWSM.
    systemd.enable = false;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "network" "pulseaudio" "backlight" "battery" "cpu" "memory" ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };
        "hyprland/window" = {
          max-length = 80;
          separate-outputs = true;
        };
        clock = {
          format = "{:%a %d %b  %H:%M}";
          tooltip-format = "<big>{:%Y-%m-%d}</big>\n<tt>{calendar}</tt>";
        };
        network = {
          format-wifi = "WiFi {signalStrength}%";
          format-ethernet = "ETH";
          format-disconnected = "Offline";
          tooltip-format = "{ifname} via {gwaddr}";
        };
        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "MUTE";
          format-icons = {
            default = [ "VOL" "VOL" "VOL" ];
          };
          on-click = "pavucontrol";
        };
        backlight = {
          format = "BRT {percent}%";
        };
        battery = {
          interval = 10;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "BAT {capacity}%";
          format-charging = "CHR {capacity}%";
        };
        cpu = {
          format = "CPU {usage}%";
          interval = 5;
        };
        memory = {
          format = "RAM {}%";
          interval = 5;
        };
      };
    };
    style = ''
      * {
        font-family: monospace;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(17, 17, 27, 0.9);
        color: #cdd6f4;
        border-bottom: 1px solid #89b4fa;
      }

      #workspaces button {
        color: #bac2de;
        padding: 0 8px;
      }

      #workspaces button.active {
        color: #89b4fa;
      }

      #clock,
      #network,
      #pulseaudio,
      #backlight,
      #battery,
      #cpu,
      #memory,
      #tray {
        margin: 0 6px;
      }
    '';
  };

  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun";
      show-icons = true;
      matching = "fuzzy";
      width = 700;
    };
  };

  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      layer = "top";
      font = "monospace 10";
      background-color = "#11111b";
      text-color = "#cdd6f4";
      border-color = "#89b4fa";
      border-radius = 8;
      margin = "10";
      padding = "10";
      "default-timeout" = 5000;
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };
      background = [
        {
          path = "screenshot";
          blur_passes = 2;
          blur_size = 6;
        }
      ];
      input-field = [
        {
          size = "260, 50";
          position = "0, -80";
          monitor = "";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 420;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  services.cliphist.enable = true;
  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;
  services.playerctld.enable = true;

  home.packages = with pkgs; [
    brightnessctl
    grim
    hyprpicker
    mise
    pavucontrol
    pamixer
    playerctl
    polkit_gnome
    slurp
    swappy
    wl-clipboard
    (writeShellScriptBin "hypr-window-switch" ''
      selected=$(
        hyprctl clients -j \
          | ${jq}/bin/jq -r '.[] | select(.mapped) | "\(.address) | [\(.workspace.name)] \(.class): \(.title)"' \
          | rofi -dmenu -p Window
      )

      if [ -n "$selected" ]; then
        address=''${selected%% | *}
        hyprctl dispatch focuswindow "address:$address"
      fi
    '')
  ];
}
