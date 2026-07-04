# this file only runs if nu is the default shell on startup
if (($env.WAYLAND_DISPLAY? | is-empty) and ($env.XDG_VTNR? == "1")) {
  exec start-hyprland
}

