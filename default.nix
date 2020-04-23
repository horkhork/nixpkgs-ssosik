{ system ? builtins.currentSystem, ... }:

let
  pkgs = import <nixpkgs> { inherit system; };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = {
    dnscrypt-proxy2-blacklist-updater = callPackage ./dnscrypt-proxy2-blacklist-updater.nix { };
  };
in
self
