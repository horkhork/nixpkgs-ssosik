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
     systemd = {
       timers.dnscrypt-proxy2-blacklist-updater = {
         description = "Make the dnscrypt-proxy2-blacklist-updater a periodic job";
         wantedBy = [ "multi-user.target" ];
         partOf = [ "dnscrypt-proxy2-blacklist-updater.service" ];
         timerConfig = {
           OnCalendar = "00:00";
           #OnCalendar = "minutely";
           Persistent = true;
           Unit = "dnscrypt-proxy2-blacklist-updater.service";
         };
       };
       services.dnscrypt-proxy2-blacklist-updater = {
         description = "Oneshot task to update the dnscrypt-proxy2 blacklist data";
         after = [ "network.target" ];
         wantedBy = [ "multi-user.target" ];
         requiredBy = [ "dnscrypt-proxy2.service" ];
         serviceConfig = {
           Type = "oneshot";
           User = "${cfg.user}";
           WorkingDirectory = "${updater}";
         };
         script = ''
           echo "Start Time: $(date)" >> /var/lib/dnscrypt-proxy2/blacklist-update.txt
           bin/generate-domains-blacklist.py -i -c \
             domains-blacklist.conf -r \
             domains-time-restricted.txt -w \
             domains-whitelist.txt > \
             /var/lib/dnscrypt-proxy2/dnscrypt-proxy-blacklist.txt
           systemctl restart dnscrypt-proxy2.service
           echo "Done Time: $(date)" >> /var/lib/dnscrypt-proxy2/blacklist-update.txt
         '';
       };
     };
   };
 }
