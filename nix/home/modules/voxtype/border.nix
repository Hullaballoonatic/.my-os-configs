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
          hyprctl eval 'hl.config({ general = { col = { active_border = { colors = { "rgba(${colors.base08}ff)", "rgba(${colors.base07}ff)", "rgba(${colors.base00}ff)" }, angle = 45 } } } })'
          ;;
        transcribing)
          hyprctl eval 'hl.config({ general = { col = { active_border = { colors = { "rgba(${colors.base09}ff)", "rgba(${colors.base0A}ff)" }, angle = 45 } } } })'
          ;;
        *)
          hyprctl eval 'hl.config({ general = { col = { active_border = "rgb(${colors.base0D})" } } })'
          ;;
      esac
    '';
  };

  voxtypeBorderIndicator = pkgs.writeText "voxtype-border-indicator.py" ''
    import json
    import os
    import selectors
    import socket
    import subprocess
    import time
    from contextlib import contextmanager

    FRAME_INTERVAL = 1 / 20
    SOCKET_PATH = os.path.join(
        os.environ["XDG_RUNTIME_DIR"], "hypr",
        os.environ["HYPRLAND_INSTANCE_SIGNATURE"], ".socket.sock",
    )

    def border_command(state, angle):
        gradients = {
            "recording": ["${colors.base08}ff", "${colors.base07}ff", "${colors.base00}ff"],
            "transcribing": ["${colors.base09}ff", "${colors.base0A}ff"],
        }
        palette = gradients.get(state, ["${colors.base0D}ff"])
        lua_colors = ", ".join(json.dumps("rgba(" + color + ")") for color in palette)
        return (
            "eval hl.config({ general = { col = { active_border = { colors = { "
            + lua_colors + " }, angle = " + str(angle) + " } } } })"
        ).encode()

    def render(state, angle=45):
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
            connection.settimeout(2)
            connection.connect(SOCKET_PATH)
            connection.sendall(border_command(state, angle))
            response = connection.recv(65536).decode()
            if response.strip() != "ok":
                raise RuntimeError(response)

    @contextmanager
    def status_stream():
        status = subprocess.Popen(
            ["${config.services.voxtype.package}/bin/voxtype", "status", "--follow", "--format", "json"],
            stdout=subprocess.PIPE,
            bufsize=0,
        )
        try:
            yield status.stdout
        finally:
            status.terminate()
            status.wait(timeout=5)

    def follow_status():
        render("idle", 0)
        with status_stream() as stream, selectors.DefaultSelector() as selector:
            selector.register(stream, selectors.EVENT_READ)
            state = "idle"
            started = time.monotonic()
            next_frame = started
            while True:
                timeout = max(0, next_frame - time.monotonic()) if state == "recording" else None
                if selector.select(timeout):
                    line = stream.readline()
                    if not line:
                        raise RuntimeError("Voxtype status stream ended")
                    new_state = json.loads(line).get("alt", "idle")
                    if new_state != state:
                        state = new_state
                        started = time.monotonic()
                        next_frame = started
                        render(state, 0 if state == "idle" else 45)
                if state == "recording" and time.monotonic() >= next_frame:
                    angle = int((time.monotonic() - started) * 120) % 360
                    render(state, angle)
                    next_frame = time.monotonic() + FRAME_INTERVAL

    follow_status()
    '';
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
      ExecStart = "${pkgs.python3}/bin/python3 ${voxtypeBorderIndicator}";
      ExecStopPost = "${setVoxtypeBorder}/bin/set-voxtype-border idle";
      Restart = "always";
      RestartSec = 1;
    };

    Install.WantedBy = ["hyprland-session.target" "voxtype.service"];
  };
}
