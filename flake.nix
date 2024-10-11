{
  inputs = {
    common.url = "github:YuMingLiao/common";
    nixpkgs.follows = "common/nixpkgs";
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
          haskellProjects.default = {
            basePackages = pkgs.haskell.packages.ghc9101;
            settings = {
              websockets.jailbreak = true;
              bytebuild.jailbreak = true;
              chronos.jailbreak = true;
            };
            packages = {
              websockets.source = "0.13.0.0";
            };
          };

          packages.default = self'.packages.replica; 
        };
    };
}
