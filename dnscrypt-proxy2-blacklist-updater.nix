 {config, lib, pkgs, ...}:
 
 let
   updater = pkgs.callPackage ./default.nix {};

   cfg = config.services.dnscrypt-proxy2-blacklist-updater;
 in
 
 {
   options = {
     services.dnscrypt-proxy2-blacklist-updater = {
       enable = lib.mkOption {
         default = false;
         type = with lib.types; bool;
         description = ''
           Enable a blacklist updater for dnscrypt-proxy2
         '';
       };
 
       user = lib.mkOption {
         default = "root";
         type = with lib.types; uniq string;
         description = ''
           Name of the user.
         '';
       };
     };
   };
 
   config = lib.mkIf cfg.enable {
     #systemd.services.ircSession = {
     #  wantedBy = [ "multi-user.target" ]; 
     #  after = [ "network.target" ];
     #  description = "Start the irc client of username.";
     #  serviceConfig = {
     #    Type = "forking";
     #    User = "${cfg.user}";
     #    ExecStart = ''${pkgs.screen}/bin/screen -dmS irc ${pkgs.irssi}/bin/irssi'';         
     #    ExecStop = ''${pkgs.screen}/bin/screen -S irc -X quit'';
     #  };
     #};

     services.cron = {
       enable = true;
       systemCronJobs = [
         "0 0 * * *      ${cfg.user}    ${updater}/bin/generate-domains-blacklist.py -i -c ${updater}/domains-blacklist.conf -r ${updater}/domains-time-restricted.txt -w ${updater}/domains-whitelist.txt > /var/lib/dnscrypt-proxy2/dnscrypt-proxy-blacklist.txt"
       ];
     };
 
     #environment.systemPackages = [ pkgs.dnscrypt-proxy2 pkgs.dnscrypt-proxy2-blacklist-updater ];
   };
 }
