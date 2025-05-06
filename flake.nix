{
  description = "The flake for html_test";

  outputs =
    { self, nixpkgs }:
    {
      packages =
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "armv6l-linux"
            "armv7l-linux"
            "i686-linux"
            "aarch64-darwin"
            "powerpc64le-linux"
            "riscv64-linux"
          ]
          (system: {
            default = nixpkgs.legacyPackages.${system}.rustPlatform.buildRustPackage {
              pname = "html_test";
              version = "0.1.0";
              src = ./.;
              cargoLock.lockFile = ./Cargo.lock;
            };
          });
      nixosModules.default =
        { config, lib, ... }:
        let
          cfg = config.services.html-test;
        in
        {
          options = {
            services.html-test.enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
          config = lib.mkIf cfg.enable {
            systemd.services.html-test = {
              description = "Serves a simple HTML file";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              path = [ self.packages.${builtins.currentSystem}.default ];
              serviceConfig = {
                ExecStart = "/usr/bin/env html_test";
                Restart = "always";
              };
            };
            networking.firewall.allowedTCPPorts = [ 80 ];
          };
        };
    };
}
