===========================================
Individuelle Anpassungen NUT Server Dateien
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
- optional: Skript für eigene Bedürfnisse anpassen

ups.conf
--------
- USV spezifische Angaben und Treiber anpassen in den Zeilen 117, 119 und 121
- evtl. 'offdelay' und 'ondelay' in Zeilen 132 und 139 anpassen
- optional: Zeilen 145-148 

upsd.conf
---------
- in der Zeile 111 für '192.168.xxx.xxx' die IP-Adresse des NUT-Servers eintragen

upsd.users
----------
- evtl. NUT User / Passwort für NUT-Server und NUT-Client anpassen

upsmon.conf
-----------
- in der Zeile 62 die UPS-Monitor Server-Verbindung zum NUT-Server mit UPS-Name,
  IP-Adresse NUT-Server, NUT-Server-Name / Passwort herstellen

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
