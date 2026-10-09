{pkgs, ...}: {
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
          theme = "subtle";
        };
      };

      whisper = {
        model = "base.en";
        language = "en";
      };

      output = {
        mode = "type";
        fallback_to_clipboard = true;
      };

      osd.enabled = false;

      text.spoken_punctuation = true;
    };
  };
}
