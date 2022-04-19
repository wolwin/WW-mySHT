===========================================
Individuelle Anpassungen NUT-Client Dateien
===========================================

Für Details siehe:
https://github.com/wolwin/WW-mySHT/blob/master/README.md

===========================================

nut_notify.sh
-------------
- Email-Versand per Email-Addon Vorlage 41
- optional: Email-Versand deaktivieren in den Zeilen 17-21 mit '# ' auskommentieren

nut_schedule.sh
---------------
- Email-Versand per Email-Addon Vorlage 41
- in Zeile 3 die NUT UPS-Adresse "ups@localhost" durch "ups@192.168.xxx.xxx" ersetzen / anpassen
- optional: Skript für eigene Bedürfnisse anpassen

upsd.conf
---------
- in der Zeile 110 für '192.168.xxx.xxx' die IP-Adresse des NUT-Servers eintragen

upsd.users
----------
- evtl. NUT User / Passwort für NUT-Server und NUT-Client anpassen

upsmon.conf
-----------
- in der Zeile 61 die UPS-Monitor Client-Verbindung zum NUT-Server mit UPS-Name,
  IP-Adresse NUT-Server, NUT-Client-Name / Passwort herstellen

upssched.conf
-------------
- optional: AT Befehle anpassen 

===========================================

Angepasste NUT Konfigurationsdateien 

nut.conf
nut_notify.sh
nut_schedule.sh
ups.conf
upsd.conf
upsd.users
upsmon.conf
upssched.conf

kopieren nach:
/usr/local/etc/config/nut

===========================================

NUT Datei

nutshutdown

kopieren nach:
/usr/local/etc/config/rc.d/nutshutdown

Datei-Rechte anpassen:
user-rights: 0755 - root [0]

===========================================
