 {config, lib, pkgs, ...}:
 
 let
   updater = pkgs.callPackage ./default.nix {};

   cfg = config.services.dnscrypt-proxy2-blacklist-updater;

   blacklist-sources = if builtins.length cfg.domains-blacklist > 0
     then pkgs.writeTextFile {
       name="blacklist-sources";
       text=lib.concatMapStringsSep "\n" (x: x) cfg.domains-blacklist;
     }
     else "${updater}/domains-blacklist.conf";

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
         type = with lib.types; uniq str;
         description = ''
           Name of the user.
         '';
       };

       domains-blacklist = lib.mkOption {
         default = [];
         type = with lib.types; listOf str;
         description = ''
           List of all sources of blacklists. If not specified, defaults to what
           is in the git repo.
         '';
       };


     };
   };
 
   config = lib.mkIf cfg.enable {
     systemd = {
       timers.dnscrypt-proxy2-blacklist-updater = {
         description = "Make the dnscrypt-proxy2-blacklist-updater a periodic job";
         before = [ "dnscrypt-proxy2" ];
         wantedBy = [ "basic.target" ];
         partOf = [ "dnscrypt-proxy2-blacklist-updater.service" ];
         timerConfig = {
           OnCalendar = "daily";
           OnBootSec = 30;
           Unit = "dnscrypt-proxy2-blacklist-updater.service";
         };
       };
       services.dnscrypt-proxy2-blacklist-updater = {
         preStart = ''
           ln -sfv ${blacklist-sources} /var/lib/dnscrypt-proxy2/blacklist-sources.txt
         '';
         description = "Oneshot task to update the dnscrypt-proxy2 blacklist data";
         after = [ "network.target" ];
         before = [ "dnscrypt-proxy2" ];
         wantedBy = [ "basic.target" ];
         requiredBy = [ "dnscrypt-proxy2.service" ];
         serviceConfig = {
           Type = "oneshot";
           User = "${cfg.user}";
           WorkingDirectory = "${updater}";
         };
         script = ''
           echo "Start Time: $(date)" >> /var/lib/dnscrypt-proxy2/blacklist-update.txt
           bin/generate-domains-blacklist.py -i \
             -c domains-blacklist.conf \
             -r domains-time-restricted.txt \
             -w domains-whitelist.txt > \
             /var/lib/dnscrypt-proxy2/dnscrypt-proxy-blacklist.txt
           systemctl restart dnscrypt-proxy2.service
           echo "Done Time: $(date)" >> /var/lib/dnscrypt-proxy2/blacklist-update.txt
         '';
       };
     };
   };
 }
