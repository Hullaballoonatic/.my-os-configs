{ pkgs, lib, ... }: {
  imports = [
    ../../home/darwin.nix
    ../../home/modules/activemq/home.nix
    ../../home/modules/colima/home.nix
    ../../home/modules/docker/home.nix
    ../../home/modules/ghostty/home.nix
  ];

  home.packages = with pkgs; [
    # Provides `node` and `npx`. Required by the Copilot CLI MCP servers in
    nodejs_22

    (lib.lowPrio pkgs.jmeter)
    maven
    grafana-loki
    bruno
    (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
      gcloud-crc32c
    ]))
  ];
}
