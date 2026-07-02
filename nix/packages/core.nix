{ pkgs }:

with pkgs; [
  # bootstrap
  git
  stow # config applier

  # terminal
  atuin # history
  bat # cat replacement
  carapace # autocompletions
  fd # find replacement
  fzf # fuzzy finding
  gh # github cli and authentiaction
  htop # system monitor
  jq # json querying
  lsd # improved colorful ls
  ncdu # disk usage viewer
  neovim # editor
  nushell # shell
  ripgrep # better grep
  sd # find & replace replacement
  sesh # tmux session manager
  starship # line
  tmux # multiplexer
  tree-sitter # dependency for many cool things
  yazi # file explorer
  zoxide # cd replacement

  # LSPs
  bash-language-server
  marksman
  markdownlint-cli2
  stylua
  lua-language-server
  nixd
  yaml-language-server
]

