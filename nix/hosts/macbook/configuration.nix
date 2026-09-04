{ self, username, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  homebrew = {
    enable = true;

    casks = [
      # Ghostty isn't buildable on aarch64-darwin in the currently pinned
      # nixpkgs revision, so it stays managed declaratively via Homebrew.
      "ghostty"
    ];

    onActivation = {
      # Don't touch anything not declared above yet; the rest of the
      # existing Homebrew installation is being migrated incrementally.
      cleanup = "none";
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
