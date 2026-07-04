{
	wayland.windowManager.hyprland = {
    enable = true;
		xwayland.enable = true;

		extraLuaFiles = {
			"init.lua" = {
				autoLoad = true;
				content = ./init.lua;
			};	
			"noctalia.lua" = {
				content = ./noctalia.lua;
			};
		};
	};
}
