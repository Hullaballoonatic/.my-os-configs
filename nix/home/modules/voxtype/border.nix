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
          hyprctl eval 'hl.config({ general = { border_size = 2, col = { active_border = { colors = { "rgba(${colors.base08}ff)", "rgba(${colors.base0E}ff)" }, angle = 45 } } } })'
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
      pkgs.hyprland
      pkgs.jq
    ];
    text = ''
      ${setVoxtypeBorder}/bin/set-voxtype-border idle

      ${config.services.voxtype.package}/bin/voxtype status --follow --format json \
        | jq --unbuffered -r .alt \
        | while IFS= read -r state; do
            ${setVoxtypeBorder}/bin/set-voxtype-border "$state"
          done
    '';
  };
in {
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

    Install.WantedBy = ["hyprland-session.target" "voxtype.service"];
  };
}
