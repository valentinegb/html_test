{
  description = "The flake for html_test";

  outputs =
    { nixpkgs, ... }:
    let
      package = nixpkgs.rustPlatform.buildRustPackage {
        pname = "html_test";
        version = "0.1.0";
        src = ./.;
        cargoLock.lockFile = ./Cargo.lock;
      };
    in
    {
      packages = {
        x86_64-linux.default = package;
        x86_64-darwin.default = package;
        aarch64-linux.default = package;
        aarch64-darwin.default = package;
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
