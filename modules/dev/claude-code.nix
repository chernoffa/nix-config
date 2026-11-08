{ inputs, ... }:

{
  flake.modules.homeManager.base =
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
              builtins.replaceStrings
                [ certStoreFlag ]
                [
                  "${certStoreFlag} --set-default NODE_EXTRA_CA_CERTS ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                ]
                old.installPhase;
          })
        else
          pkgs.claude-code;

      # OptMem's memo, pinned to nix's python3 since it may not be on PATH.
      memo = pkgs.runCommand "optmem-memo" { } ''
        install -Dm755 ${inputs.optmem}/memo $out
        substituteInPlace $out \
          --replace-fail '#!/usr/bin/env python3' '#!${pkgs.python3}/bin/python3'
      '';

      # The `## Memory` block `memo init` prints, generated from a throwaway
      # store laid out like the real one so its paths read ~/.optmem/...
      memoryPrompt = pkgs.runCommand "optmem-prompt.md" { } ''
        export HOME=$TMPDIR
        install -Dm755 ${memo} $HOME/.optmem/memo
        $HOME/.optmem/memo init | sed -n '/^## Memory$/,$p' > $out
        grep -q '~/.optmem/memo wake' $out
      '';
    in
    {
      home.packages = [ claude-code ];

      home.file.".optmem/memo".source = memo;
      home.file.".claude/CLAUDE.md".source = memoryPrompt;

      # `memo init` only creates what is missing, so this never touches
      # existing memories.
      home.activation.optmemInit = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        run --quiet ${memo} init
      '';
    };
}
