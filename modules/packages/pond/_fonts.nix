{
  lib,
  stdenvNoCC,
  fetchurl,
  fetchzip,
}:

# The two typefaces Pond's interface uses that nixpkgs lacks, from the same
# sources pond-pkgbuilds packages them from.
{
  onest = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "onest";
    version = "2.001";

    src = fetchzip {
      url = "https://github.com/simpals/onest/releases/download/${finalAttrs.version}/onest-${finalAttrs.version}.zip";
      hash = "sha256-g0kREzehNdp5bnKQWZTSMByZGROcwjN7rcz+G/lDkh0=";
    };

    installPhase = ''
      runHook preInstall
      install -Dm644 'fonts/variable/Onest[wght].ttf' $out/share/fonts/truetype/Onest.ttf
      runHook postInstall
    '';

    meta = {
      description = "Onest variable sans-serif font family";
      homepage = "https://github.com/simpals/onest";
      license = lib.licenses.ofl;
    };
  });

  advent-pro =
    let
      # The Google Fonts revision pond-pkgbuilds pins.
      base = "https://raw.githubusercontent.com/google/fonts/fffdadf0f0c9cc1ec8b407063424a8bfbee05611/ofl/adventpro";
      regular = fetchurl {
        name = "AdventPro.ttf";
        url = "${base}/AdventPro%5Bwdth%2Cwght%5D.ttf";
        hash = "sha256-tgqykguJvcS32t+ygsraxuA4M+eoCET56sCWNZsrl2Y=";
      };
      italic = fetchurl {
        name = "AdventPro-Italic.ttf";
        url = "${base}/AdventPro-Italic%5Bwdth%2Cwght%5D.ttf";
        hash = "sha256-CRel1lWJAl8qdSsbBWj5JNrEmgZaJbTWARazxtTZ664=";
      };
    in
    stdenvNoCC.mkDerivation {
      pname = "advent-pro";
      version = "3.0.0";

      dontUnpack = true;

      installPhase = ''
        runHook preInstall
        install -Dm644 ${regular} $out/share/fonts/truetype/AdventPro.ttf
        install -Dm644 ${italic} $out/share/fonts/truetype/AdventPro-Italic.ttf
        runHook postInstall
      '';

      meta = {
        description = "Advent Pro variable sans-serif font family";
        homepage = "https://fonts.google.com/specimen/Advent+Pro";
        license = lib.licenses.ofl;
      };
    };
}
