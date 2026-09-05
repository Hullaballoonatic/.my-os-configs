{ self, pkgs, username, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Mirrors desktop's config - weekly GC (keep last 14 days) + store
  # optimisation, since Homebrew casks/formulae + nix-darwin generations
  # can otherwise accumulate significant unreferenced store paths.
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 3; Minute = 0; };
    options = "--delete-older-than 14d";
  };

  nix.optimise = {
    automatic = true;
    interval = { Weekday = 0; Hour = 4; Minute = 0; };
  };

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
  ];

  homebrew = {
    enable = true;

    casks = [
      # Ghostty isn't buildable on aarch64-darwin in the currently pinned
      # nixpkgs revision, so it stays managed declaratively via Homebrew.
      "ghostty"

      # GitHub's own CLI, not a nixpkgs package (nixpkgs' unrelated
      # `copilot-cli`/`github-copilot-cli` attrs are EOL/unavailable).
      "copilot-cli"

      # GUI app; not (yet) attempted via Nix.
      "bruno"
    ];

    onActivation = {
      # Migration is complete - Homebrew is now fully declarative. Any
      # cask/formula/tap not listed above gets uninstalled automatically
      # on the next switch (this is what will finally remove gcloud-cli
      # now that it's dropped above).
      cleanup = "uninstall";
      autoUpdate = false;
      upgrade = false;
    };
  };

  system = {
    primaryUser = username;
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 6;
  };
}
