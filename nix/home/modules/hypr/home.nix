{
	wayland.windowManager.hyprland = {
    enable = true;
		xwayland.enable = true;

		extraLuaFiles = {
			"init.lua" = {
				autoLoad = true;
				content = ./init.lua;
			};	
		};
	};
}
