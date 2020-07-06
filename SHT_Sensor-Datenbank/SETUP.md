## WW-mySHT - Setup Node-RED - Datenbank

### Funktion

Erstellen der myHOME-Datenbank Tabellen mit Node-RED

### Allgemein

Das Node-RED Modul ist so ausgelegt worden, dass es ohne SQL-Kenntnisse eingesetzt werden kann. Natürlich kann die Installation auch manuell über die Befehlszeile mittels SQL-Kommandos erfolgen.

### Technische Voraussetzungen

### Setup - Teil 1 - MariaDB

Die MariaDB SQL-Datenbank muss installiert und für die Benutzung konfiguriert sein (User, Passwort, Sicherheit, etc.).

### Setup - Teil 2 - Node-RED

Überprüfen, ob Node-RED in der aktuellen Version (derzeit in der Version 0.20.5) installiert ist. Weiter muss das Modul 'node-red-node-mysql' installiert sein - siehe im Node-RED Fenster Einstellungen oben rechts und dann unter dem Menü-Eintrag 'Manage palette'. Unter dem Reiter 'Install' kann das Modul gesucht und installiert werden - falls es schon installiert ist, kann unter 'Nodes' die Version geprüft und evtl. aktualisiert werden (derzeit in der Version 0.0.18).

Für eigene Node-RED Erweiterungen sollte man einen 'public' Ordner anlegen (TTY-Konsole - als pi user):
```
mkdir /home/pi/.node-red/public
```
Node-RED stoppen:
```
node-red-stop
```
Die Node-RED 'settings.js'-Datei öffnen:
```
sudo nano /home/pi/.node-red/settings.js
```
Folgenden Eintrag vornehmen und Datei mit 'CTRL-X' - 'Ja' abspeichern:
```
httpStatic: '/home/pi/.node-red/public',
```
Node-RED starten:
```
node-red-start
```
In den 'public' Ordner wird die Konfigurationsdatei 'myHOME_Devices_WM.csv' für den Weatherman und die Konfigurationsdatei 'myHOME_Devices_FS.csv' für das Feinstaub-Modul kopiert. Die Konfiguration der Devices wird in den CSV-Dateien vorgenommen und muss als erstes durchgeführt werden - detaillierte Angaben dazu finden sich hier:

[Setup - Teil 3 - Konfiguration Weatherman Device](/myHOME%20-%20Weatherman/SETUP.md#setup---teil-3---konfiguration-weatherman-device)

[Setup - Teil 3 - Konfiguration Feinstaub Device](/myHOME%20-%20Feinstaub/SETUP.md#setup---teil-3---konfiguration-feinstaub-device)

Wer direkt mit einer Standardeinstellung loslegen möchte, der kopiert

- 'myHOME_Devices_WM_std.csv' nach 'myHOME_Devices_WM.csv'

und / oder

- 'myHOME_Devices_FS_std.csv' nach 'myHOME_Devices_FS.csv'

### Setup - Teil 3 - Node-RED Datenbank

Kopieren des Datenbank Node-RED Moduls, indem die Datei 'myHOME_FLOW_Datenbank_xxx.md' auf die Flow Ebene von Node-RED im Explorer gezogen wird.

Im Flow 'myHOME - Datenbank' stehen im ersten Beschreibungsnode '01 - ...' die SQL-Befehle, mit denen die myHOME-Datenbank manuell angelegt werden muss:

```
# Eine vorhandene myHOME-Datenbank loeschen
DROP DATABASE IF EXISTS `myHOME`;

# Eine neue myHOME-Datenbank anlegen
CREATE DATABASE `myHOME` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
```

 Dies kann einfach über die TTY-Konsole erfolgen:

```
pi@RASPI-DATA:~ $ sudo mysql -p -u root
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 25
Server version: 10.1.23-MariaDB-9+deb9u1 Raspbian 9.0

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> DROP DATABASE IF EXISTS `myHOME`;
Query OK, 0 rows affected, 1 warning (0.00 sec)

MariaDB [(none)]> CREATE DATABASE `myHOME` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
Query OK, 1 row affected (0.00 sec)

MariaDB [(none)]> exit
Bye
```

Damit ist die myHOME-Datenbank angelegt.

Als nächstes wird - wie im Beschreibungsnode '02 - ...' aufgeführt - der 'myHOME' Node mit der MariaDB Datenbank verbunden:
- den 'myHOME' Node mit einem Doppelklick öffnen und die 'Database myHOME' editieren (Stift anklicken)
- die Host IP-Adresse der MariaDB (192.168.xxx.yyy), den Datenbank Port (3306), den Usernamen (root), das Passwort und den Datenbankname (myHOME) eingegeben
- die Eingaben mit dem 'Update' Knopf bestätigen
- die Eingaben mit dem 'Done' Knopf abshließen

Nach Einstellung der Datenbankparameter wird mit dem 'Deploy' Knopf die Konfiguration veröffentlicht.

Geht der 'myHOME' Datenbank-Node auf 'connected', ist die Datenbankverbindung erfogreich hergestellt worden - ansonsten noch einmal die Verbindungsparameter überprüfen.

Nun können die Datenbanktabellen 'SENSOR_DEVICES' und 'SENSOR_READINGS' angelegt werden, indem die 'Inject'-Flächen (links) der Nodes

*03 - Create table SENSOR_DEVICES*<br>
*04 - Create table SENSOR_READINGS*

angeklickt werden - bei Erfolg erscheint die Meldung: 'Succesfully injected: timestamp'.

Abschließend werden noch die CSV-Konfigurationen in die Datenbank geladen, indem die 'Inject'-Flächen (links) der Nodes

*100 - Init SENSOR_DEVICES - Weatherman*<br>
*101 - Init SENSOR_DEVICES - Feinstaub*

angeklickt werden - bei Erfolg erscheint die Meldung: 'Succesfully injected: timestamp'.

Damit ist die myHOME MariaDB betriebsbereit.

### Version

1.1.0.0 - 2019-05-10
- Fortschreibung - siehe 'Readme - SQL-Details zur WW-myHOME-Datenbank'

1.0.0.0 - 2018-12-27
- Erstausgabe


*<b>Befindet sich z.Z. noch in der Weiterentwicklung</b>*
