{ pkgs, ... }:
{
  imports = [./border.nix];

  services.voxtype = {
    enable = true;
    package = pkgs.voxtype-vulkan;

    loadModels = ["base.en"];

    settings = {
      hotkey.enabled = false;

      output.notification.on_transcription = false;

      osd.enabled = false;

      text.spoken_punctuation = true;
      text.replacements = {
        "hyper land" = "hyprland";
        "hyperland" = "hyprland";
        "ghost key" = "ghostty";
      };
    };
  };
}
