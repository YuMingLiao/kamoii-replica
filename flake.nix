{
  inputs = rec {
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      haskell-flake,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule ];

      perSystem =
        {
          self',
          pkgs,
          config,
          ...
        }:
        with pkgs.lib.fileset;
        with builtins;
        {
          haskellProjects.ghc965 = {
            basePackages = pkgs.haskell.packages.ghc965;
           };

          haskellProjects.default = {
            basePackages = config.haskellProjects.ghc965.outputs.finalPackages;
          };

          packages.default = self'.packages.replica; 
        };
    };
}
