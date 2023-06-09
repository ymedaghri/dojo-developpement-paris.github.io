{
  description = "ELM with formatting, linting and test";

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

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
      in
      {
        devShell = pkgs.mkShell {
          packages = [
            pkgs.elmPackages.elm
            pkgs.elmPackages.elm-format
            pkgs.elmPackages.elm-review
            pkgs.coreutils # provide `yes` to accept everything asked by `elm-review`
            pkgs.elmPackages.elm-test-rs
            pkgs.elmPackages.nodejs # elm-test-rs need node
            pkgs.elmPackages.elm-json
          ];
        };
      });
}
