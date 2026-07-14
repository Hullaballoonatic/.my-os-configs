{ pkgs, ... }:

{
  stylix = {
    enable = true;
    polarity = "dark";

    base16Scheme = {
      scheme = "Vicinae";
      author = "Vicinae HQ; Base16 adaptation by Casey";

      # Surfaces
      base00 = "0f1014"; # Primary background: ink-900
      base01 = "15161b"; # Secondary background: ink-800
      base02 = "1c1d23"; # Selection / elevated surface: ink-700
      base03 = "5f5b58"; # Comments / subtle text

      # Foreground
      base04 = "8a837c"; # Muted foreground
      base05 = "b0aaa4"; # Normal foreground
      base06 = "ddd8d2"; # Strong foreground
      base07 = "ede9e3"; # Bright foreground

      # Semantic colors
      base08 = "c77b75"; # Red
      base09 = "c9a76e"; # Orange / bright brass
      base0A = "d4b88e"; # Yellow / sand
      base0B = "8aaa9c"; # Green / pale sage
      base0C = "6a8a7c"; # Cyan / copper patina
      base0D = "b8944e"; # Blue role / primary brass accent
      base0E = "9b829a"; # Purple
      base0F = "9a7b3f"; # Brown / dark brass
    };

    # Change this to whichever Nerd Font you already prefer.
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      sansSerif = {
        package = pkgs.google-fonts.override {
          fonts = [ "Outfit" ];
        };
        name = "Outfit";
      };

      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 11;
        desktop = 11;
        popups = 11;
        terminal = 12;
      };
    };

    opacity = {
      applications = 1.0;
      desktop = 1.0;
      popups = 1.0;
      terminal = 1.0;
    };

    targets.zen-browser.profileNames = ["Default Profile"];
  };
}
