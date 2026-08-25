{ pkgs, ... }:

{
  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Let a flake opt into binary caches through its own `nixConfig`
  # (teachme_web's flake pulls ruby from nixpkgs-ruby.cachix.org).
  # Listing the cache in `trusted-substituters` is not enough: the matching
  # `trusted-public-keys` is a restricted setting, so the daemon keeps warning
  # "ignoring the client-specified setting" for every untrusted user - on every
  # `nix develop` / direnv load. Trusting the user silences both warnings and
  # makes the cache actually apply. Which flake settings are accepted is
  # recorded per value in ~/.local/share/nix/trusted-settings.json.
  # A trusted user can effectively act as root through the daemon; acceptable
  # on a single-user dev machine.
  nix.settings.trusted-users = [ "root" "@admin" ];

  # Do not print `warning: Git tree '...' is dirty` on every flake command.
  # Entering a devShell from a dirty worktree is the normal case here.
  nix.settings.warn-dirty = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable fish and add to /etc/shells
  programs.fish.enable = true;

  # System-level packages (if needed)
  environment.systemPackages = [];

  # Homebrew casks that can't (reasonably) be installed from nixpkgs.
  # Karabiner-Elements ships a DriverKit system extension, so the official
  # pkg installer is used rather than `services.karabiner-elements`
  # (nixpkgs lags behind and re-grants of Input Monitoring would be needed).
  homebrew = {
    enable = true;
    casks = [ "karabiner-elements" ];
    # Leave manually installed brew packages alone
    onActivation.cleanup = "none";
  };

  # Used for backwards compatibility
  system.stateVersion = 6;
}
