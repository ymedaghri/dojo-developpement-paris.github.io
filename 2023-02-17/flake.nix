{
  description = "Rust with formatting, linting and test";

  # broken on Fish
  # as a workaround, use `nix develop` the first time
  # https://github.com/direnv/direnv/issues/1022
  nixConfig.extra-substituters = [
    "https://pinage404-nix-sandboxes.cachix.org"
  ];
  nixConfig.extra-trusted-public-keys = [
    "pinage404-nix-sandboxes.cachix.org-1:5zGRK2Ou+C27E7AdlYo/s4pow/w39afir+KRz9iWsZA="
  ];

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

  inputs.crane.url = "github:ipetkov/crane";
  inputs.crane.inputs.flake-utils.follows = "flake-utils";
  inputs.crane.inputs.nixpkgs.follows = "nixpkgs";
  inputs.crane.inputs.rust-overlay.follows = "rust-overlay";

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , rust-overlay
    , crane
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          rust-overlay.overlays.default
        ];
      };

      rust-toolchain = (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml);

      devShell = pkgs.mkShell {
        packages = [
          rust-toolchain
          pkgs.rustup
        ];
      };

      craneLib = (crane.mkLib pkgs).overrideToolchain rust-toolchain;

      src = craneLib.cleanCargoSource ./.;

      rust-dependencies = craneLib.buildDepsOnly {
        inherit src;
      };

      rust-package-binary = craneLib.buildPackage {
        inherit src;
        cargoArtifacts = rust-dependencies;

        doCheck = false;
      };

      app = flake-utils.lib.mkApp {
        drv = rust-package-binary;
      };
    in
    {
      # run with `nix develop`
      devShells.default = devShell;

      # run with `nix shell`
      packages.default = rust-package-binary;

      # run with `nix run`
      apps.default = app;
    });
}
