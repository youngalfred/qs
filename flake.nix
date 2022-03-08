{
  description = "reproducible batmobile develpment environment";

  inputs = {
    nixpkgs.url      = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          poetry
        ]
        ++ lib.optional stdenv.isDarwin [
          libffi
          openssl
          darwin.apple_sdk.frameworks.CoreServices
        ]
        ;

        shellHook = with pkgs; ''
          # rapidfuzz links against libstdc++.so.6 which gcc depends on
          export LD_LIBRARY_PATH=${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}
          # `poetry env info -p` is broken.
          # See: https://github.com/python-poetry/poetry/issues/1870
          # Need to do `poetry env use python3.10`
          source $(poetry env info -p)/bin/activate

          # Nope, it's too slow
          # poetry shell --no-root

          # Need to explicitly use the python version if it differs from the
          # system one. See `poetry env --list`
          # poetry use 3.10
        '';
      };
    }
  );
}
