{
  programs.difftastic.enable = true;
  programs.gh = {
    enable = true;
  };
  programs.git = {
    enable = true;

    settings = {
      aliases = {
        wl = "worktree list";
      };
      branch.sort = "-committerdate";
      core.untrackedCache = true;
      core.fsmonitor = true;
      commit.verbose = true;
      merge.conflictstyle = "zdiff3";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.autosquash = true;
      rerere.enabled = true;
      user = {
        name = "Alexander Chernoff";
        email = "alex@chernoff.xyz";
      };
    };

    ignores = [
      ".DS_STORE"
      ".claude/settings.local.json"
      ".direnv"
      ".envrc"
      ".jj"
      "*.xcodeproj/xcuserdata"
      "result"
    ];

    lfs.enable = true;
  };
}
