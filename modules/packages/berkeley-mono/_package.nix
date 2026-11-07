{
  lib,
  requireFile,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "berkeley-mono";
  version = "2.002";

  src = requireFile rec {
    name = "${finalAttrs.pname}-${finalAttrs.version}-ttf.zip";
    sha256 = "07dqfvmmjh4d15mzy4r2vx6zvb0ykb3z8f0p3dqya46ivjg12lic";
    message = ''
      This file needs to be manually downloaded from U.S. Graphics (https://usgraphics.com/).

      Configure the variant with ttf fonts & download the zip file.

      Then run:
      mv \$PWD/berkeley-mono-typeface.zip \$PWD/${name}
      nix-store --add-fixed sha256 \$PWD/${name}
    '';
  };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    install -D -m444 -t $out/share/fonts/truetype $(find . -name "*.ttf")

    runHook postInstall
  '';

  meta = {
    description = "Berkeley Mono™ is a love letter to the golden era of computing.";
    license = lib.licenses.unfree;
  };
})
