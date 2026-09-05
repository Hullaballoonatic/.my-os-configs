{ pkgs, lib, ... }: {
  imports = [
    ../../home/darwin.nix
    ../../home/modules/ghostty/home.nix
  ];

  # CLI tools migrated from Homebrew that are currently macOS-only. Not
  # shared via home/core.nix since they aren't (yet) needed on desktop -
  # move any of these into core.nix if that changes.
  home.packages = with pkgs; [
    docker
    docker-buildx
    kubectl
    activemq
    (lib.lowPrio pkgs.jmeter) # priority-demoted: its LICENSE file collides with activemq's
    maven # config lives untouched at ~/.m2/settings.xml, not managed here
    grafana-loki # provides `logcli`
    colima # docker-desktop replacement (VM state lives in ~/.colima, untouched)

    # gcloud manages its own components with `gcloud components
    # install/update`, which can't write into the read-only Nix store -
    # nixpkgs' build disables that entirely. Declare needed components
    # here instead: run `gcloud components list` to see what's active,
    # add the matching attr below, then rebuild.
    (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
      gcloud-crc32c
    ]))
  ];
}
