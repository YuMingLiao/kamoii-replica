{
  inputs = {
    common.url = "github:YuMingLiao/common";
    nixpkgs.follows = "common/nixpkgs";
  };
  outputs =
    inputs@{
      self,
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
            basePackages = config.haskellProjects.ghc9101.outputs.finalPackages;
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
