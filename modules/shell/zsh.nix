{
  flake.modules.nixos.base.programs.zsh.enable = true;

  flake.modules.homeManager.base.programs.zsh = {
    enable = true;
    autocd = true;

    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    historySubstringSearch.enable = true;
  };
}
