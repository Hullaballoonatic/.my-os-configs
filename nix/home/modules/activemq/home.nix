{ config, lib, pkgs, ... }: let
	activemqStateDir = "${config.xdg.stateHome}/activemq";
	activemqStateTarget = lib.removePrefix "${config.home.homeDirectory}/" activemqStateDir;

	activemq = pkgs.writeShellScriptBin "activemq" ''
		export ACTIVEMQ_BASE="${activemqStateDir}"
		export ACTIVEMQ_CONF="${pkgs.activemq}/conf"
		export ACTIVEMQ_DATA="${activemqStateDir}/data"
		export ACTIVEMQ_TMP="${activemqStateDir}/tmp"

		exec ${pkgs.activemq}/bin/activemq "$@"
	'';
in

{
	home.packages = [
		activemq
	];

	home.file."${activemqStateTarget}/data/.keep".text = "";
	home.file."${activemqStateTarget}/tmp/.keep".text = "";
}
