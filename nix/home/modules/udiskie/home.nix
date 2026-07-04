{
	services.udiskie = {
		enable = true;

		notify = false;
		tray = "never";

		settings = {
			program_options = {
				file_manager = "yazi";
				terminal = "ghostty";
			};
		};
	};
}
