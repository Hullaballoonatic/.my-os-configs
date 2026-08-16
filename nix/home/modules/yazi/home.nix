{
	programs.yazi = {
		enable = true;

		enableNushellIntegration = true;

		keymap = {
			mgr.prepend_keymap = [
				{
					on = ["y"];
					run = [
						''shell -- for path in %s; do echo "file://$path"; done | wl-copy -t text/uri-list''
						"yank"
					];
				}
			];
		};
	};
}
