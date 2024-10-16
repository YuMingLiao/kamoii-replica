with (import <nixpkgs> { }).lib;
with (import <nixpkgs> { }).lib.fileset;

let
  local-path = /home/nixos/fix/kamoii-replica;
  libSrc = local-path + "/src";
in
{
  src = libSrc;
  name = "kamoii-replica";
  dependencies =
    modName:
    {
      "Replica/SessionID.hs" = ["cryptonite"];
    }
    ."${modName}" or [ ]
    ++ [
      "Diff"
      "aeson"
      "async"
      "base"
      "bytestring"
      "chronos"
      "co-log-core"
      "containers"
      "file-embed"
      "hex-text"
      "http-media"
      "http-types"
      "psqueues"
      "resourcet"
      "stm"
      "template-haskell"
      "text"
      "torsor"
      "wai"
      "wai-websockets"
      "websockets"
    ];

  extensions = [
    "OverloadedStrings"
    "CPP"
    "LambdaCase"
  ];
  ghcOpts = modName: [
    "-Wall"
    "-ferror-spans"
    "-Wincomplete-uni-patterns"
    "-Wincomplete-record-updates"
    "-Wmissing-import-lists"
  ];
  extra-directories = (
    modName:
    {
      "Replica.VDOM" = 
        let extra-dir = toSource {
          root = ./.;
          fileset = js/dist/client.js; 
        };
        in
        [extra-dir];
    }
    ."${modName}" or [ ]
  );
}
