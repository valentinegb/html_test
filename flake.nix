{
  description = "The flake for html_test";

  outputs =
    { nixpkgs, ... }:
    let
      package = {
        pname = "html_test";
        version = "0.1.0";
        src = ./.;
        cargoLock.lockFile = ./Cargo.lock;
      };
    in
    {
      packages = {
        x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.rustPlatform.buildRustPackage package;
        x86_64-darwin.default = nixpkgs.legacyPackages.x86_64-darwin.rustPlatform.buildRustPackage package;
        aarch64-linux.default = nixpkgs.legacyPackages.aarch64-linux.rustPlatform.buildRustPackage package;
        aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.rustPlatform.buildRustPackage package;
      };
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
              path = [ package ];
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
