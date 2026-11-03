{
  description = "Multi-Machine Dendritic NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # AI coding agents / desktop apps (Claude Desktop, etc.)
    # Intentionally NOT setting inputs.nixpkgs.follows: the flake is built & cached
    # against its own pinned nixpkgs-unstable, so omitting `follows` lets us pull
    # prebuilt binaries from their binary cache instead of rebuilding locally.
    llm-agents.url = "github:numtide/llm-agents.nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }@inputs: {
    nixosConfigurations = {
      
      # Machine 1: Asus ROG Zephyrus G14
      "g14-laptop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/g14-laptop/configuration.nix
        ];
      };
      "dell-laptop" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/dell-laptop/configuration.nix
        ];
      };
    };
  };
}
