{stdenv, docker, gnugrep, gawk, ...}:

stdenv.mkDerivation rec {
  name = "dab";
  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    cp dab $out/bin/
  '';

  propagatedBuildInputs = [
    docker
    gnugrep
    gawk
  ];

  meta = {
    description = "The Developer Lab";
    longDescription = ''
      The Developer Lab, for developing with docker.
    '';
    downloadPage = https://github.com/Nekroze/dab/raw/master/dab;
    license = stdenv.lib.licenses.gpl3;
    maintainer = let
      nekroze = {
        name = "Taylor 'Nekroze' Lawson";
        github = "Nekroze";
        email = "nekroze.lawson@gmail.com";
      };
    in [ nekroze ];
    platforms = stdenv.lib.platforms.unix;
  };
}
