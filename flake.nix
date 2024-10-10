{
  inputs = {
    common.url = "github:YuMingLiao/common";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      common,
      ...
    }:
    common.lib.mkFlake { inherit inputs; } {
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
