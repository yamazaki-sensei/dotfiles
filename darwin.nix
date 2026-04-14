{ pkgs, ... }:

{
  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable fish and add to /etc/shells
  programs.fish.enable = true;

  # System-level packages (if needed)
  environment.systemPackages = [];

  # Used for backwards compatibility
  system.stateVersion = 6;
}
