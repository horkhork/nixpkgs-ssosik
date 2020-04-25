# Below, we can supply defaults for the function arguments to make the script
# runnable with `nix-build` without having to supply arguments manually.
# Also, this lets me build with Python 3.7 by default, but makes it easy
# to change the python version for customised builds (e.g. testing).
{ nixpkgs ? import <nixpkgs> {}, pythonPkgs ? nixpkgs.pkgs.python37Packages }:

let
  # This takes all Nix packages into this scope
  inherit (nixpkgs) pkgs;
  # This takes all Python packages from the selected version into this scope.
  inherit pythonPkgs;

  # Inject dependencies into the build function
  f = { buildPythonPackage, bottle, requests }:
    buildPythonPackage rec {
      pname = "dnscrypt-proxy2-blacklist-updater";
      version = "1.0";

      src = builtins.fetchFromGitHub {
        owner = "jedisct1";
        repo = "dnscrypt-proxy";
        rev = version;
        sha256 = "1v4n0pkwcilxm4mnj4fsd4gf8pficjj40jnmfkiwl7ngznjxwkyw";
      };

      buildPhase = ''
        # Skip build
      '';
      checkPhase = ''
        # Skip check
      '';

      installPhase = ''
        mkdir -p $out/bin
        cp $src/utils/generate-domains-blacklists/generate-domains-blacklist.py $out/bin/generate-domains-blacklist.py
        cp $src/utils/generate-domains-blacklists/domains-blacklist.conf $out/domains-blacklist.conf
        cp $src/utils/generate-domains-blacklists/domains-time-restricted.txt $out/domains-time-restricted.txt
        cp $src/utils/generate-domains-blacklists/domains-whitelist.txt $out/domains-whitelist.txt
      '';

      meta = {
        description = "";
        #license = licenses.isc;
        homepage = "";
        #maintainers = with maintainers; [ ssosik ];
        #platforms = with platforms; unix;
      };
    };

  drv = pythonPkgs.callPackage f {};
in
  if pkgs.lib.inNixShell then drv.env else drv

