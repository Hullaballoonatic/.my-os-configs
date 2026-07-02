$env.config.show_banner = false

$nu.data-dir | path join "vendor/autoload" | mkdir $in

$env.PATH = (
  # for macos
  $env.PATH
    | split row (char env_sep)
    | append ~/.nix-profile/bin
    | append /nix/var/nix/profiles/default/bin
)

# history
atuin init nu | save -f ($nu.data-dir | path join "vendor/autoload/atuin.nu")

# autocompletions
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
carapace _carapace nushell | save -f ($nu.data-dir | path join "vendor/autoload/carapace.nu")

# terminal line
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# smarter cd with z
zoxide init nushell | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")

