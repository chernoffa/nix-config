{
  lib,
  requireFile,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "berkeley-mono";
  version = "2.002";

  srcTTF = requireFile rec {
    name = "${finalAttrs.pname}-${finalAttrs.version}-ttf.zip";
    sha256 = "07dqfvmmjh4d15mzy4r2vx6zvb0ykb3z8f0p3dqya46ivjg12lic";
    message = ''
      This file needs to be manually downloaded from U.S. Graphics (https://usgraphics.com/).

      Configure the variant with ttf fonts & download the zip file.

      Then run:
      mv \$PWD/berkeley-mono-typeface.zip \$PWD/${name}-ttf.zip
      nix-prefetch-url --type sha256 file://\$PWD/${name}-ttf.zip
    '';
  };

  srcOTF = requireFile rec {
    name = "${finalAttrs.pname}-${finalAttrs.version}-otf.zip";
    sha256 = "06phscc13ymk2hxjz1cg059303x1lqxwx1hjh44sq7hc9xwnvzsa";
    message = ''
      This file needs to be manually downloaded from U.S. Graphics (https://usgraphics.com/).

      Configure the variant with otf fonts & download the zip file.

      Then run:
      mv \$PWD/berkeley-mono-typeface.zip \$PWD/${name}-otf.zip
      nix-prefetch-url --type sha256 file://\$PWD/${name}-otf.zip
    '';
  };

  outputs = [
    "out"
  ];

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip $srcTTF
    unzip $srcOTF
  '';

  installPhase = ''
    runHook preInstall

    install -D -m444 -t $out/share/fonts/opentype $(find . -name "*.otf")
    install -D -m444 -t $out/share/fonts/truetype $(find . -name "*.ttf")

    runHook postInstall
  '';

  meta = {
    description = "Berkeley Mono™ is a love letter to the golden era of computing.";
    license = lib.licenses.unfree;
  };
})
