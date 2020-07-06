## WW-myHOME - Setup Node-RED - Feinstaub

### Funktion
Übernahme, Aufbereitung, Deployment und Visualisierung der per WiFi versandten Sensordaten der Sensordaten der Feinstaub Messstation (https://luftdaten.info/) durch Node-RED

### Allgemein

Das Node-RED Modul ist so ausgelegt worden, dass es universiell konfiguriert und eingesetzt werden kann. Dies gilt sowohl für die technischen Voraussetzungen, als auch für die Modul interne Konfiguration. Im Folgenden wird das Aufsetzen einer Minimal-Version, einer (sinnvollen) Standard-Version und der maximalen (Debug) Version gezeigt.
Besonderer Wert wurde bei der Entwicklung darauf gelegt, dass das Deployment der Sensordaten individuell konfigurierbar ist. So werden z.B. in der Standardeinstellung nur die Sensordaten weiterverarbeitet, die sich geändert haben - dies sorgt besonders bei der MQTT Weitergabe oder dem Abspeichern in einer Datenbank für eine starke Reduzierung des Datenverkehrs bzw. für deutlich weniger Speicherplatzbedarf!

### Technische Voraussetzungen

Als Hardware Grundlage wird ein Raspberry Pi mit einer aktuellen Debian Version benötigt. Folgende Software Module werden für die einzelnen Ausbaustufen benötigt:

- Minimal-Version
  - Funktion: Übernahme, Aufbereitung und Visualisierung der Weatherman Sensordaten
  - Software Module:
    - Node-RED Installation (z.Z.: latest version ... v0.20.5 (npm))


- Standard-Version
  - Funktion: Übernahme, Aufbereitung, Deployment und Visualisierung der Weatherman Sensordaten
  - Software Module:
    - Node-RED Installation (z.Z.: latest version ... v0.20.5 (npm))
    - MQTT Broker - Mosquitto
    - optional: MariaDB SQL-Datenbank


- Maximal-Version
  - Funktion: wie Standard-Version - nur mit allen Optionen und (Debug) Möglichkeiten zur eigenen Anpassung
  - Software Module:
    - Node-RED Installation (z.Z.: latest version ... v0.20.5 (npm))
    - MQTT Broker - Mosquitto
    - MariaDB SQL-Datenbank

Die Installation von Node-RED, Mosquitto und MariaDB wird hier nicht im Einzelnen dargestellt. Es macht jedoch Sinn, alle Module so aufzusetzen, dass sie über sichere Verbindungen miteinander kommunizieren.
In der eigenen myHOME-Umgebung laufen so z.B. Node-RED, FHEM und Grafanna über einem Nginx Proxy Server.

### Setup - Teil 1 - Feinstaub

- die Sensordaten des Feinstaub Moduls werden über den Port 8182 in Node-RED abgegriffen
- dazu muss beim im Feinstaub Modul unter 'Konfiguration' eingestellt werden:
  - 'An eigene API senden' - angehakt
    - Server: <IP-NodeRED-Server\>
    - Pfad: /feinstaub
    - Port: 8182

### Setup - Teil 2 - Node-RED

Überprüfen, ob Node-RED in der aktuellen Version installiert ist. Weiter muss das Modul 'node-red-dashboard' installiert sein - siehe im Node-RED Fenster Einstellungen oben rechts und dann unter dem Menü-Eintrag 'Manage palette'. Unter dem Reiter 'Install' kann das Modul gesucht und installiert werden - falls es schon installiert ist, kann unter 'Nodes' die Version geprüft und evtl. aktualisiert werden.

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

### Setup - Teil 3 - Konfiguration Feinstaub Device

Hier finden sich die Device CSV-Konfigurationsdateien für das Feinstaub Modul:

[myHOME_Devices_FS_all.csv](./bin/myHOME_Devices_FS_all.csv)<br>
[myHOME_Devices_FS_std.csv](./bin/myHOME_Devices_FS_std.csv)

Die CSV-Dateien sind vorkonfiguriert und können sofort benutzt werden. Bitte die CSV-Dateien bei einer Anpassung NICHT mit MS Excel editieren - besser: Notepad++ benutzen (UTF-8 Zeichensatz)!!

Erläuterungen zu den CSV-Spalten finden sich in der Beschreibung:

[Datenbank-Tabelle - SENSOR_DEVICES](../myHOME%20-%20Datenbank/README.md#datenbank-tabelle---sensor_devices)

Anpassung der barometrischen Ortshöhen-Beschreibung "hPa (190 m ü. N.N.)" in der Zeile 23 der Datei 'myHOME_Devices_xxx.csv' von '190' auf den N.N. Höhenwert, auf den der gemessene barometrische Wert reduziert werden soll.

Für das Feinstaub Modul werden die im JSON-String übergebenen 'value_type'-Bezeichnungen neu 'normiert' - damit braucht keine Code-Anpassung der Folge-Prozesse mehr erfolgen, wenn bei einer Firmware-Änderung Namenseinträge geändert werden - bei den Folgeprozessen bleiben die festgelegten Device Bezeichner und Zuordnungen erhalten:

  - DEV_TYP<br>
    'normierte' Bezeichnung - z.B.: 'fs_sds011_pm2_5'
  - DEV_OLD_NAME<br>
    JSON-Name alt - 'value_type' oder ''
  - DEV_OLD_TYP<br>
    JSON-Typ alt - z.B.: 'SDS_P1' oder ''

Eine Gegenüberstellung der 'normierte' Bezeichnung zu den 'value_type' Bezeichnungen findet sich hier:

[myHOME_Datenbank_SQL_Names_FS.txt](./bin/myHOME_Datenbank_SQL_Names_FS.txt)

Optional können Anpassungen für jeden DEVICE-Eintrag in den folgenden Spalten vorgenommen werden:

  - ID_DEV<br>
    lfd. Device-ID Nummer - Aufbau 'xxxyyy' mit
    - xxx = der IP-Adresse 192.168.010.xxx<br>
     '1' ... '254'
    - yyy = 3stelliger Index<br>
      '000' ... '999'
  - DEV_DESC<br>
    Device-Bezeichnung - z.B.: 'Feinstaub-Sensor'
  - DEV_LOC<br>
    Device-Standort - z.B.: 'Garten' oder ''
  - DEV_VAL_DESC<br>
    Wert-Bezeichnung - z.B.: 'PM2.5' oder ''
  - DEV_VAL_UNIT<br>
    Wert-Einheit - z.B.: 'µg/m³' oder ''
  - DEV_MQTT<br>
    MQTT-Ausgabepfad - z.B.: '/myHOME/sensor/devices/<DEV_NAME>' oder '' (für das DEVICE keine MQTT-Ausgabe)
  - DEV_FL_ACT<br>
    Flag-DEV Aktiv - '0 ... 255' (0 = DEVICE-Eintrag ist nicht aktiv)
  - DEV_FL_STO<br>
    Flag-DEV Speichern - '0 ... 255' (0 = DEVICE-Daten nicht in DB speichern)
  - DEV_FL_MQTT<br>
    Flag-DEV MQTT-Ausgabe - '0 ... 255' (0 = DEVICE-MQTT nicht ausgeben)

Kopieren der angepaßten 'myHOME_Devices_xxx.csv' Dateien nach '/home/pi/.node-red/public'

- für die Minimal- und Standard-Version
  - 'myHOME_Devices_WM_std.csv' nach 'myHOME_Devices_WM.csv' kopieren
- für die Maximal-Version
  - 'myHOME_Devices_WM_max.csv' nach 'myHOME_Devices_WM.csv'

### Setup - Teil 4 - Konfiguration  Datenbank

Für die Standard-Version mit Datenbank Option und für die Maximal-Version muss die 'MariaDB SQL-Datenbank' installiert und konfiguriert werden:

[WW-myHOME - Datenbank - Setup.md](../myHOME%20-%20Datenbank/README.md)

### Setup - Teil 5 - Node-RED Feinstaub

Kopieren des Feinstaub Node-RED Moduls, indem die Datei 'myHOME_FLOW_Feinstaub_xxx.md' auf die Flow Ebene von Node-RED im Explorer gezogen wird.

Mit einem Doppelklick auf den Node 'Init-Flow' die Anpassungen für das Feinstaub Modul vornehmen.

- *var myBaro_NN = 190;*<br>
Altitude [m] - eigene Ortshöhe über N.N. zur Berechnung des barometrischen Luftdrucks in Bezug zu N.N.. Von dem Wert '190' auf den N.N. Höhenwert, auf den der gemessene barometrische Wert umgerechnet werden soll, ändern<br>
  - Definitionen:
    - absoluter Luftdruck = Luftdruckmessung am Standort des WM (ohne Korrekturwert)
    - relativer Luftdruck - auf Meereshöhe reduzierter Luftdruckmesswert NN des WM (mit Korrekturwert)
  - Im FS kann keine Ortshöhe zur Korrektur eingegeben werden - es wird immer der absolute Luftdruck bereitgestellt => es muss hier 'var myBaro_NN = <Ortshoehe>;' gesetzt werden, um auch den relativen Luftdruckwert ermitteln zu können.
  - Wird hier 'var myBaro_NN = 0;' eingegeben, dann wird der Luftdruckwert des FS ohne Korrektur ausgegeben.
  - Mit der Ortshöhe werden automatisch die richtigen Werte für 'wm_baro' (absoluter Luftdruck) und 'wm_baro_nn' (relativer Luftdruck) gesetzt - das gilt auch für die Werteanzeigen 'Luftdruck' und 'Luftdruck NN' im Dashboard.

- *var myTmpNewOnly_Default = 1;*<br>
Flow-Vorgabe, ob nur neue Readings (Werte) oder alle Readings eines Devices berücksichtigt werden sollen<br>
= 0 - alle Readings<br>
&gt; 0 - nur neue Readings<br>

- *var myDbData_Flag = 1;*<br>
Flow-Vorgabe, ob die Werte eines Devices in eine myHOME Datenbank abgespeichert werden<br>
= 0 - keine DB Data Ausgabe<br>
&gt; 0 - DB Data Ausgabe<br>

  - für die Minimal-Version<br>
    *var myDbData_Flag = 0;*<br>
  - für die Standard-Version nur, wenn optional eine mariaDB SQL Datenbank installiert ist kann das Abspeichern gewählt werden, sonst<br>
  *var myDbData_Flag = 0;*<br>

- *var myMqttData_Flag = 1;*<br>
Flow-Vorgabe, ob eine MQTT Ausgabe für die Devices erfolgen soll<br>
= 0 - keine MQTT Data Ausgabe<br>
&gt; 0 - MQTT Data Ausgabe<br>

  - für die Minimal-Version<br>
    *var myMqttData_Flag = 0;*<br>

- *var myMqttState_Flag = 1;*<br>
*var myMqttState_DevName = "Feinstaub";*<br>
*var myMqttState_DevMqtt = "/myHOME/sensor/devices/Feinstaub/state";*<br>
Flow-Vorgabe, ob eine MQTT Status Ausgabe für die Devices erfolgen soll<br>
= 0 - keine MQTT Status Ausgabe<br>
&gt; 0 - MQTT Status Ausgabe

  - für die Minimal-Version<br>
    *var myMqttState_Flag = 0;*<br>

- *var myMqttAvg_Flag = 1;*<br>
*var myMqttAvg_DevMqtt = "/myHOME/sensor/devices/Feinstaub/avg";*<br>
Flow-Vorgabe, ob eine MQTT Ausgabe für den gleitenden Mittelwert (AVG) aller numerischen Felder der Devices erfolgen soll<br>
= 0 - keine MQTT AVG Ausgabe<br>
&gt; 0 - MQTT AVG Ausgabe<br>

  - für die Minimal-Version<br>
    *var myMqttAvg_Flag = 0;*<br>

Den 'Init-Flow' Node mit dem 'Done' Knopf schließen.

Dann müssen noch in den MQTT-Ausgabe Nodes die MQTT-Broker Adressen eingetragen werden (gilt nicht für Minimal-Version).

Ebenfalls müssen die myHOME Datenbank Nodes verbunden werden (gilt nicht für Minimal-Version).

Abschließend wird der Weatherman Flow mit dem 'Deploy' Knopf veröffentlicht.

Über '&lt;node-RED URL&gt;/ui' im Browser sollte nun der Feinstaub Bereich mit den Anzeigen erscheinen.

Wenn alles wie vorgesehen funktioniert, können aus dem Feinstaub-Flow die nicht benötigten Nodes (z.B.: alle Debug-Nodes, der Node Switch SYS  und evtl. auch die DB-OUT Database bzw. DB-OUT MQTT Bereiche) gelöscht werden. Ebenfalls können in den Nodes Switch VAR und Switch AVG die nicht benötigten Abfragen entfernt werden.

Man kann das Modul auch als reines 'Feinstaub to MQTT' Modul ohne jegliche Anzeige einsetzen - dann können alle Switch xxx Nodes und alle Anzeigen gelöscht werden. Die Feinstaub Ausgaben erfolgen dann an einen MQTT-Broker, der wiederum dafür sorgt, dass z.B. ein Node-RED MQTT Feinstaub Client (myHOME_FLOW_Feinstaub_MQTT_xxx.md) die Daten anzeigt oder dass FHEM die MQTT-Daten entgegen nimmt (fhem_cfg_WM.txt - siehe bin-Ordner).

Nach der Bereinigung wird mit dem 'Deploy' Knopf die Änderung veröffentlicht.

### Version

1.1.0.0 - 2019-05-10
- Anpassung für barometrische Höhenkorrektur 'myBaro_NN'

1.0.0.0 - 2018-12-26
- Erstausgabe
