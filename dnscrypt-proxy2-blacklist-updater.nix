{ stdenv, python3Packages, fetchFromGitHub }:

# TODOs
#  - get dnscrypt-proxy2-blacklist-updater into git somewhere and pull it in
#  - Add crontab entry here with options
#  - Based on options generate domains-blacklist.conf, domains-whitelist, time-restricted, custom
#  - actually hook up to dnscrypt-proxy2
#  - run cronjob as non-root
#  - instead of cron, run the updater as a systemd unit

python3Packages.buildPythonApplication rec {
  pname = "dnscrypt-proxy2-blacklist-updater";
  version = "1.0";

  src = fetchFromGitHub {
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

  meta = with stdenv.lib; {
    description = "A tool that can be added to crontab for automatically updating dnscrypt-proxy2 blacklists";
    license = licenses.isc;
    homepage = "";
    maintainers = with maintainers; [ ssosik ];
    platforms = with platforms; unix;
  };
}
