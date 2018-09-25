with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "dab-shell";
  buildInputs = [
    ((callPackage ../default.nix) {})
  ];
}
