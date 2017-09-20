export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
alias nixosre='nix-store --gc;'\
    'nixos-rebuild switch --upgrade'\
    '-I "jrakoczy-pkgs=https://github.com/jrakoczy/aux-nixpkgs/archive/master.tar.gz"'\
