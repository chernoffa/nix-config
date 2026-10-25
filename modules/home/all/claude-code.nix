{ pkgs, lib, ... }:

let
  # nixpkgs sets CLAUDE_CODE_CERT_STORE=system, which on darwin reads only the
  # Keychain (not SSL_CERT_FILE or /etc/ssl/certs), leaving no public roots.
  # Add the nix cacert bundle so TLS works and still tracks cacert updates.
  certStoreFlag = "--set-default CLAUDE_CODE_CERT_STORE system";
  claude-code =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.claude-code.overrideAttrs (old: {
        installPhase =
          assert lib.assertMsg (lib.hasInfix certStoreFlag old.installPhase)
            "claude-code: wrapper no longer sets CLAUDE_CODE_CERT_STORE; revisit this override";
          builtins.replaceStrings [ certStoreFlag ] [
            "${certStoreFlag} --set-default NODE_EXTRA_CA_CERTS ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          ] old.installPhase;
      })
    else
      pkgs.claude-code;
in
{
  home.packages = [ claude-code ];
}
