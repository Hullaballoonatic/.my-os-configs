{
  config,
  pkgs,
  ...
}: let
  colors = config.lib.stylix.colors;

  setVoxtypeBorder = pkgs.writeShellApplication {
    name = "set-voxtype-border";
    runtimeInputs = [pkgs.hyprland];
    text = ''
      case "''${1:-idle}" in
        recording)
          hyprctl eval 'hl.config({ general = { border_size = 2, col = { active_border = "rgb(${colors.base0D})" } } })'
          ;;
        transcribing)
          hyprctl eval 'hl.config({ general = { border_size = 2 } })'
          hyprctl eval 'hl.config({ general = { col = { active_border = { colors = { "rgba(${colors.base09}ff)", "rgba(${colors.base0A}ff)" }, angle = 45 } } } })'
          ;;
        *)
          hyprctl eval 'hl.config({ general = { border_size = 2 } })'
          hyprctl eval 'hl.config({ general = { col = { active_border = "rgb(${colors.base0D})" } } })'
          ;;
      esac
    '';
  };

  voxtypeBorderIndicator = pkgs.writeShellApplication {
    name = "voxtype-border-indicator";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.hyprland
      pkgs.jq
    ];
    text = ''
      ${setVoxtypeBorder}/bin/set-voxtype-border idle

      ${config.services.voxtype.package}/bin/voxtype status --follow --format json \
        | jq --unbuffered -r .alt \
        | while IFS= read -r state; do
            if [ "$state" = recording ]; then
              ${setVoxtypeBorder}/bin/set-voxtype-border recording
              mkdir -p "${config.xdg.cacheHome}/voxtype"
              while [ "$(cat "''${XDG_RUNTIME_DIR}/voxtype/state")" = recording ]; do
                if hyprctl activewindow -j \
                  | jq --compact-output '{at: .at, size: .size, monitor: .monitor, address: .address}' \
                      > "${config.xdg.cacheHome}/voxtype/border-window.json.tmp"; then
                  mv "${config.xdg.cacheHome}/voxtype/border-window.json.tmp" \
                    "${config.xdg.cacheHome}/voxtype/border-window.json"
                fi
                sleep 0.05
              done
              printf '{}' > "${config.xdg.cacheHome}/voxtype/border-window.json"
            else
              mkdir -p "${config.xdg.cacheHome}/voxtype"
              printf '{}' > "${config.xdg.cacheHome}/voxtype/border-window.json"
              ${setVoxtypeBorder}/bin/set-voxtype-border "$state"
            fi
          done
    '';
  };
in {
  services.voxtype = {
    enable = true;
    package = pkgs.voxtype-vulkan;

    loadModels = ["base.en"];

    settings = {
      hotkey.enabled = false;

      audio = {
        device = "default";

        feedback = {
          enabled = true;
          theme = "default";
          volume = 0.2;
        };
      };

      whisper = {
        model = "base.en";
        language = "en";
      };

      output = {
        mode = "type";
        fallback_to_clipboard = true;

        notification = {
          on_recording_start = false;
          on_recording_stop = false;
          on_transcription = false;
        };
      };

      osd.enabled = false;

      text.spoken_punctuation = true;
    };
  };

  systemd.user.services.voxtype-border-indicator = {
    Unit = {
      Description = "Show Voxtype state on the active window border";
      After = ["voxtype.service" "hyprland-session.target"];
      PartOf = ["hyprland-session.target" "voxtype.service"];
      Requires = ["voxtype.service"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${voxtypeBorderIndicator}/bin/voxtype-border-indicator";
      ExecStopPost = "${setVoxtypeBorder}/bin/set-voxtype-border idle";
      Restart = "always";
      RestartSec = 1;
    };

    Install.WantedBy = ["hyprland-session.target"];
  };

  home.packages = [pkgs.quickshell];

  xdg.configFile."quickshell/voxtype-border.qml".text = ''
    import QtQuick
    import Quickshell
    import Quickshell.Wayland
    import Quickshell.Io

    ShellRoot {
      FileView {
        id: windowState
        path: "${config.xdg.cacheHome}/voxtype/border-window.json"
        watchChanges: true
      }

      Variants {
        model: Quickshell.screens

        PanelWindow {
          required property var modelData
          screen: modelData
          anchors {
            top: true
            bottom: true
            left: true
            right: true
          }
          color: "transparent"
          mask: Region {}

          exclusionMode: ExclusionMode.Ignore
          WlrLayershell.layer: WlrLayer.Overlay
          WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

          Canvas {
            id: canvas
            anchors.fill: parent

            property var frame: {
              try { return JSON.parse(windowState.text()); }
              catch (error) { return {}; }
            }
            property bool hasFrame: !!(
              frame.at && frame.size && frame.at.length >= 2 && frame.size.length >= 2
              && frame.at[0] < modelData.x + width
              && frame.at[0] + frame.size[0] > modelData.x
              && frame.at[1] < modelData.y + height
              && frame.at[1] + frame.size[1] > modelData.y
            )
            visible: hasFrame

            Timer {
              interval: 16
              running: canvas.hasFrame
              repeat: true
              onTriggered: canvas.requestPaint()
            }

            onPaint: {
              const ctx = getContext("2d");
              ctx.clearRect(0, 0, width, height);
              if (!hasFrame)
                return;

              const x = frame.at[0] - modelData.x;
              const y = frame.at[1] - modelData.y;
              const w = frame.size[0];
              const h = frame.size[1];
              const inset = 3;
              const left = x + inset;
              const top = y + inset;
              const right = x + w - inset;
              const bottom = y + h - inset;
              const perimeter = 2 * ((right - left) + (bottom - top));
              const distance = (Date.now() % 1100) / 1100 * perimeter;
              const point = distance < right - left
                ? [left + distance, top]
                : distance < right - left + bottom - top
                  ? [right, top + distance - (right - left)]
                  : distance < 2 * (right - left) + bottom - top
                    ? [right - (distance - (right - left) - (bottom - top)), bottom]
                    : [left, bottom - (distance - 2 * (right - left) - (bottom - top))];

              ctx.strokeStyle = "#${colors.base0F}";
              ctx.lineWidth = 3;
              ctx.strokeRect(left, top, right - left, bottom - top);

              const glow = ctx.createRadialGradient(point[0], point[1], 0, point[0], point[1], 24);
              glow.addColorStop(0, "#${colors.base07}");
              glow.addColorStop(0.35, "#${colors.base09}");
              glow.addColorStop(1, "#${colors.base09}00");
              ctx.fillStyle = glow;
              ctx.beginPath();
              ctx.arc(point[0], point[1], 24, 0, Math.PI * 2);
              ctx.fill();
            }

            Component.onCompleted: requestPaint()
          }
        }
      }
    }
  '';

  systemd.user.services.voxtype-border-overlay = {
    Unit = {
      Description = "Draw a traveling highlight around the focused window while Voxtype records";
      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.quickshell}/bin/quickshell --no-duplicate --path ${config.xdg.configHome}/quickshell/voxtype-border.qml";
      Restart = "on-failure";
      RestartSec = 1;
    };

    Install.WantedBy = ["hyprland-session.target"];
  };
}
