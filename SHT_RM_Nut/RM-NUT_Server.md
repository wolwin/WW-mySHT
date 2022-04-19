# WW-mySHT - Einbinden einer USV in die 'RaspberryMatic' mit den 'Network UPS Tools' - Server-Installation

[Zurück zur Übersicht ...](../README.md)

- Weiter zu: [I.) 'RaspberryMatic' und 'Network UPS Tools' ...](./README.md)

- Weiter zu: [II.) 'RaspberryMatic' als 'NUT-Client' konfigurieren ...](./RM-NUT_Client.md)

- Weiter zu: [IV.) 'RaspberryMatic' Erweiterungen der 'NUT' Konfiguration (Client und Server) ...](./RM-NUT_Xtend.md)

- Weiter zu: [V.) 'RaspberryMatic' und 'NUT' Monitoring (Client und Server) ...](./RM-NUT_HM-Mon.md)

### III.) 'RaspberryMatic' als 'NUT-Server' konfigurieren

Ist die 'RaspberryMatic' mit ihrer Stromversorgung an eine USV angeschlossen, die von keinem 'NUT-Server' gemanagt wird, dann wird die 'RaspberryMatic' als 'NUT-Server' konfiguriert. Die Konfigurationsdateien können mit 'WinSCP' editiert werden.

Als erstes ist zu verifizieren, welche USV in 'NUT' eingebunden werden soll, damit der korrekte Treiber ausgewählt werden kann. Dies ist wichtig, da es je Treiber unterschiedliche Parameter gibt, die eine ordnungsgemäße Funktion des Shutdown Prozesses sicherstellen sollen: [über 100 verschiedene Hersteller und Modelle](https://networkupstools.org/stable-hcl.html).

Im Beispiel ist die USV eine 'Back-UPS CS 650' der Firma APC – dafür wird der Treiber 'usbhid-ups' benötigt.

##### nut.conf
Diese Datei teilt den 'Network UPS Tools' mit, in welchem Modus sie ausgeführt werden sollen. Abhängig von dieser Einstellung werden dann die benötigten Module gestartet. Es wird eingetragen, dass es sich um einen 'NUT-Server' handelt:
-	Anpassen der Datei */etc/config/nut/nut.conf*
  - Eintrag 'MODE=none' ändern in:
```
MODE=netserver
```

##### ups.conf
Diese Datei wird von der 'Network UPS Tools' Treibersteuerung gelesen. Es teilt 'NUT' mit, mit welcher Art von USV-Gerät es arbeiten soll. Einige Einstellungen zur Steuerung der Kommunikation mit dem USV-Gerät können konfiguriert werden – außerdem können einige der USV-Geräteparameter überschrieben werden. Hier wird der 'NUT-Server' für die angeschlossene USV konfiguriert:
-	Anpassen der Datei */etc/config/nut/ups.conf*
  -	Nach der letzten Kommentarzeile einfügen:
```
# Set maxretry to 3 by default, this should mitigate race with slow devices:
maxretry = 3
```
```
[ups]
    desc = "APC Back-UPS CS 650"
    # driver.name
    driver = "usbhid-ups"
    # driver.parameter.port
    port = "auto"
    # driver.parameter.pollintervall
    pollinterval = 15
```
```
    # driver.parameter.lowbatt
    # sets also the default value for battery.charge.low
    lowbatt = 33
```
```
    # driver.parameter.offdelay
    # sets also ups.delay.shutdown
    # Set the timer before the UPS is turned off after the kill power command is sent (via the -k switch)
    offdelay = 120
```
```
    # driver.parameter.ondelay
    # sets also ups.delay.start
    # Set the timer for the UPS to switch on in case the power returns after the kill power command had been
    # sent, but before the actual switch off. This ensures the machines connected to the UPS are, in all cases,
    # rebooted after a power failure. Usually this must be greater than offdelay
    ondelay = 130
```
```
    # Optional. When you specify this, the driver ignores a low battery condition flag that is
    # reported by the UPS (some devices will switch off almost immediately after setting this
    # flag, or will report this as soon as the mains fails). Instead it will use either of the
    # following conditions to determine when the battery is low
    ignorelb
    override.battery.charge.low = 33
    override.battery.charge.warning = 50
    override.battery.runtime.low = 300
```
  - Erläuterung:

          - Die APC USV mit dem NUT-Device Namen 'ups' wird über den USB-Port 'automatisch' mit dem Treiber 'usbhid‑ups' eingebunden. Die untere Schwelle der Batterie-Kapazität wird mit 'lowbatt' auf 33% gesetzt, damit die USV nach Wiederkehren der Stromversorgung direkt starten kann, ohne vorher lange die USV-Batterie erst laden zu müssen.
          - Mit dem 'offdelay' Eintrag wird der Zeitraum (in Sekunden) für das Abschalten der UPS nach dem 'kill power'-Befehl definiert. Mit 120 Sekunden ist ausreichend Zeit, um die 'RaspberryMatic' definiert herunterzufahren, bevor die USV sich ausschaltet – der Wert kann bei Bedarf geändert werden.
          - Mit dem 'ondelay' Eintrag wird die Zeit (in Sekunden) angegeben, die von der USV nach dem Wiederkehren des Stroms gewartet wird, bis die angeschlossenen Geräte wieder mit Strom versorgt werden. Der Wert von 'ondelay' muß größer als der Wert von 'offdelay' sein.
          - Optional kann mit 'ignorelb' der USV-Treiber das Flag für niedrigen Batteriezustand, welches von der USV gemeldet wird, ignorieren - einige USV-Geräte schalten sich fast sofort nach dem Setzen dieses Flags aus oder melden dies, sobald das Stromnetz ausfällt. Stattdessen werden die folgenden 'override' Bedingungen verwendet, um festzustellen, wann die Batterie schwach ist.


#### upsmon.conf
Die Hauptaufgabe dieser Datei besteht darin, die Systeme zu definieren, die 'upsmon' überwacht, und 'NUT' mitzuteilen, wie das System bei Bedarf heruntergefahren werden soll. Hier wird die Verbindung zum 'NUT-Server' eingetragen.
-	Anpassen der Datei */etc/config/nut/upsmon.conf*
  - Eintrag '# MONITOR ups@bigserver 1 <USERNAME> <PASSWORD> slave' ändern in:
    ```
    MONITOR <UPSNAME>@<IP-ADRESS> 1 <USERNAME> <PASSWORD> master
    ```
    |||
    | --- | --- |
    | \<UPSNAME\> | Name des UPS-Devices des 'NUT-Servers' (z.B.: ups) |
    | \<IP-ADRESS\> | IP-Adresse des 'NUT-Servers' (z.B.: 192.168.10.114) |
    | \<USERNAME\> | 'NUT-Client' Nutzername (z.B.: upsmaster) |
    | \<PASSWORD\> | Passwort (z.B.: geheim) |

  - Beispiel:
    ```
    MONITOR ups@192.168.10.114 1 upsmaster geheim master
    ```

  - <u>Anmerkung</u>: für die Verbindung zu einem ein Synology NAS muss immer <USERNAME> 'monuser' und <PASSWORD> 'secret' verwendet werden (d.h. es muss kein NAS Nutzer angelegt werden).

##### nut_notify.sh
  In der Datei 'upsmon.conf' wird mit der Zeile 'NOTIFYCMD /etc/config/nut/nut_notify.sh' festgelegt, dass das 'nut_notify.sh' Skript aufgerufen wird, sobald 'NUT' ein angeschlossenes USV-System identifiziert, das Aufmerksamkeit erfordert. Mit diesem Skript wird eine Alarm-Meldung an die 'RaspberryMatic' geschickt:

  ```
  # trigger a HomeMatic alarm message to "${UPSNAME}-Alarm"
  /bin/triggerAlarm.tcl "${NOTIFYTYPE}" "${UPSNAME}-Alarm"
  ```

##### upsd.conf
  Diese Datei kontrolliert den Zugriff auf den 'NUT-Server' (hier: über 'localhost' und IP-Adresse) – es können verschiedene Verbindungskonfigurationswerte gesetzt werden (siehe # Kommentare):

  -	Anpassen der Datei /etc/config/nut/upsd.conf
    -	Nach der letzten Kommentarzeile einfügen:
      ```
      LISTEN <IP-ADRESS> 3493
      ```
      |||
      | --- | --- |
      | \<IP-ADRESS\> |	IP-Adresse des 'NUT-Servers' (z.B.: 192.168.10.114) |

    - Beispiel:
      ```
      LISTEN 127.0.0.1 3493
      LISTEN 192.168.10.114 3493
      ```

##### upsd.users
  'NUT' Verwaltungsbefehle wie das Festlegen von Variablen oder die Sofortbefehle sind systemrelevant – daher muss der Zugriff darauf eingeschränkt werden. Diese Datei definiert, wer darauf zugreifen darf und was verfügbar ist.

  Jeder Benutzer bekommt seinen eigenen Abschnitt. Die Felder in diesem Abschnitt legen die Parameter fest, die den Berechtigungen dieses Benutzers zugeordnet sind. Der Abschnitt beginnt mit dem Namen des Benutzers in Klammern und wird bis zum nächsten Benutzernamen in Klammern oder EOF fortgesetzt. Diese Benutzer sind unabhängig von den Benutzer in '/etc/passwd'.

  -	Anpassen der Datei */etc/config/nut/upsd.users*
    -	Nach der letzten Kommentarzeile einfügen:
      ```
      [<USERNAME-M>]
      password = <PASSWORD-M>
      upsmon master
      ```    
      ```
      [<USERNAME-S>]
      password = <PASSWORD-S>
      upsmon slave
      ```    
      |||
      | --- | --- |
      | \<USERNAME-M\> |	'NUT-Server' Nutzername (z.B.: upsmaster) |
      | \<PASSWORD-M\> |	Passwort (z.B.: geheim) |
      | \<USERNAME-S\> |	'NUT-Client' Nutzername (z.B.: monuser) |
      | \<PASSWORD-S\> |	Passwort (z.B.: pass) |

      - Beispiel:
        ```
        [upsmaster]
        password = geheim
        # Allow changing values of certain variables in the UPS
        actions = SET
        # Allow setting the 'Forced Shutdown' flag in the UPS
        actions = FSD
        instcmds = ALL
        upsmon master

        [monuser]
        password = pass
        upsmon slave
        ```

##### upssched.conf
Diese Datei steuert die Operationen von 'upssched', dem zeitgeberbasierten Hilfsprogramm für 'upsmon'. Hier können eigene Skripte definiert werden, die bei bestimmten Ereignissen ausgeführt werden.

  -	Anpassen der Datei /etc/config/nut/upssched.conf
    - 'CMDSCRIPT' Eintrag ändern in:
      ```
      CMDSCRIPT /usr/bin/nut_upssched.sh
      ```
    - '#' Kommentarzeichen vor den 'PIPEFN' und 'LOCKFN' entfernen und Pfadangaben ändern in:
      ```
      PIPEFN /var/state/ups/upssched.pipe
      LOCKFN /var/state/ups/upssched.lock
      ```
    -	Nach der letzten Kommentarzeile die unten aufgeführten 'AT' Befehlszeilen einfügen einfügen:
      ```
      AT ONBATT * START-TIMER onbatt 30
      AT ONLINE * CANCEL-TIMER onbatt online
      AT LOWBATT * EXECUTE onbatt
      AT COMMBAD * START-TIMER commbad 30
      AT COMMOK * CANCEL-TIMER commbad commok
      AT NOCOMM * EXECUTE commbad
      AT SHUTDOWN * EXECUTE powerdown
      ```

      - Erläuterung:
        - 'CMDSCRIPT' ist der Pfad zu dem Skript, das ausgeführt werden soll, wenn USV-Trigger gesetzt wurden, die dann die Eventnachrichten an dieses Script weitergeben. Als Beispiel ist dazu die Datei 'nut_schedule.sh' beigefügt (siehe unten), die Email-Nachrichten verschickt. 'PIPEFN' und 'LOCKFN' werden genutzt, um mit den Prozessen (Start- und Stop-Timer) zu agieren. Sie werden automatisch erzeugt und gelöscht - die Ordner müssen für den Prozess beschreibbar sein.
        - Es werden Timer für 'onbatt'. und 'commbad' benutzt, um innerhalb von jeweils 30 Sekunden zu entscheiden, ob wirklich ein entsprechender Event vorliegt.

##### nut_schedule.sh
  Erweiterung: für den 'NUT-Client' und 'NUT-Server' werden die 'HomeMatic' Email-Systemvariablen gesetzt (16 => '### NUT-USV ###') und dann der Email-Versand für das Email-Template '41' durchgeführt.
  -	Optional, wenn in 'upssched.conf' definiert: Anlegen der Datei /etc/config/nut/nut_schedule.sh
    -	Datei 'nut_schedule.sh' mit folgendem Inhalt anlegen:
    - Datei-Rechte auf '0x0755' – 'root[0]' setzen

```
#!/bin/sh

myUpsName="ups@localhost"
myMsg="NUT-Meldung von [`hostname`]: $1\n"

SCRIPTPATH=$(cd `dirname $0` && pwd)
"$SCRIPTPATH/Msg2Var.tcl" "16" "sv_EM-SUBJ-PRE"
"$SCRIPTPATH/Msg2Var.tcl" "$1" "sv_EM-SUBJ"

case $1 in
	onbatt)
		STAT=`upsc $myUpsName ups.status`
		BATT=`upsc $myUpsName battery.charge`
		RUNTIME=`upsc $myUpsName battery.runtime`
                RUNTIME_S="$(printf "%02d:%02d:%02d" "$(($RUNTIME / 3600))" "$(($RUNTIME / 60))" "$(($RUNTIME % 60))")"
                myMsg="$myMsg\nDas System laeuft seit mehr als 5 Minuten im Batteriebetrieb.\n"
                myMsg="$myMsg\nUSV-Status : $STAT"
                myMsg="$myMsg\nUSV-Detail : Batterie: $BATT% geladen - Laufzeit: $RUNTIME_S Stunden"
                myMsg="$myMsg\nUSV-Modus  : Batteriebetrieb\n"
                ;;

        online)
		STAT=`upsc $myUpsName ups.status`
		BATT=`upsc $myUpsName battery.charge`
		RUNTIME=`upsc $myUpsName battery.runtime`
                RUNTIME_S="$(printf "%02d:%02d:%02d" "$(($RUNTIME / 3600))" "$(($RUNTIME / 60))" "$(($RUNTIME % 60))")"
                myMsg="$myMsg\nDas System laeuft jetzt wieder im Netzbetrieb.\n"
                myMsg="$myMsg\nUSV-Status : $STAT"
                myMsg="$myMsg\nUSV-Detail : Batterie: $BATT% geladen - Laufzeit: $RUNTIME_S Stunden"
                myMsg="$myMsg\nUSV-Modus  : Netzbetrieb\n"
                ;;

	commbad)
                myMsg="$myMsg\nDas System hat die Verbindung mit der USV verloren!\n"
                ;;

	commok)
		STAT=`upsc $myUpsName ups.status`
		BATT=`upsc $myUpsName battery.charge`
		RUNTIME=`upsc $myUpsName battery.runtime`
                RUNTIME_S="$(printf "%02d:%02d:%02d" "$(($RUNTIME / 3600))" "$(($RUNTIME / 60))" "$(($RUNTIME % 60))")"
                myMsg="$myMsg\nDas System hat die Verbindung mit der USV wieder hergestellt.\n"
                myMsg="$myMsg\nUSV-Status : $STAT"
                myMsg="$myMsg\nUSV-Detail : Batterie: $BATT% geladen - Laufzeit: $RUNTIME_S Stunden"
                myMsg="$myMsg\nUSV-Modus  : Netzbetrieb\n"
                ;;

	powerdown)
		STAT=`upsc $myUpsName ups.status`
		BATT=`upsc $myUpsName battery.charge`
		RUNTIME=`upsc $myUpsName battery.runtime`
                RUNTIME_S="$(printf "%02d:%02d:%02d" "$(($RUNTIME / 3600))" "$(($RUNTIME / 60))" "$(($RUNTIME % 60))")"
                myMsg="$myMsg\n!!! Das System faehrt wegen eines Stromausfalls herunter!!!\n"
                myMsg="$myMsg\nUSV-Status : $STAT"
                myMsg="$myMsg\nUSV-Detail : Batterie: $BATT% geladen - Laufzeit: $RUNTIME_S Stunden"
                myMsg="$myMsg\nUSV-Modus  : Ausschalten\n"
                ;;

	*)
                # echo "wrong parameter"
                myMsg="$myMsg\nDas System meldet einen unbekannten Parameter.\n"
                ;;

esac

# echo "$myMsg"

"$SCRIPTPATH/Msg2Var.tcl" "${myMsg}" "sv_EM-TEXT"
"/etc/config/addons/email/email" "41"

exit 0
```

##### nutshutdown
  Die Datei 'nutshutdown' wird zum Ende des 'NUT' Herunterfahren-Prozesses ausgeführt, um die USV gezielt als letztes Gerät auszuschalten. Regulär wird diese Datei automatisch vom 'NUT' Installationspaket in '/lib/systemd/system-shutdown' angelegt und ist damit im Shutdown Prozess des Systems integriert.

  Auf der RaspberryMatic gibt es keine 'systemd' Funktionalität und damit ist per Default keine 'nutshutdown' Funktion vorhanden. Diese Funktion kann jedoch nachgebildet werden, indem man so vorgeht:

  -	Einfügen der Datei /usr/local/etc/config/rc.d/nutshutdown
    - Datei 'nutshutdown' mit folgendem Inhalt anlegen:
    - Datei-Rechte auf '0x0755' – 'root[0]' setzen

```
#!/bin/sh

# /usr/local/etc/config/rc.d/nutshutdown
# user-rights: 0755 - root [0]

case "$1" in
""|start)
  # RM Startup
  ;;
stop)
  # RM Shutdown
  # NUT-Original: /sbin/upsmon -K >/dev/null 2>&1 && /sbin/upsdrvctl shutdown
  # Test for the UPS shutdown flag
  if /usr/sbin/upsmon -K >/dev/null 2>&1; then
    # Stop UPS driver instance
    /usr/sbin/upsdrvctl stop
    sleep 2
    # Call UPS shutdown
    /usr/sbin/upsdrvctl shutdown
    # Send email
    /etc/config/addons/email/email 47
  fi
  ;;
Esac
```

  - Erläuterung:
    - 'nutshutdown' überprüft zuerst, ob das 'Shutdown-Flag' gesetzt worden ist. Ist dies der Fall, wird mit dem Befehl 'upsdrvctl shutdown' auch die USV (zeitgesteuert) heruntergefahren.
    - Dies funktioniert auf einem 'Debian' System problemlos, da zu diesem Zeitpunkt die Treiber-Instanz (hier: 'usbhid‑ups') schon beendet ist. Anders beim 'RaspberryMatic'-System: 'nutshutdown' wird in '/usr/local/etc/config/rc.d/' ausgeführt. Zu diesem Zeitpunkt ist die Treiber-Instanz noch nicht beendet worden. Vor dem 'upsdrvctl shutdown' Befehl muss mit 'upsdrvctl stop' die Treiber-Instanz beendet werden, da es sonst zu einem undefinierten Fehler kommt und die USV nicht (zeitgesteuert) herunterfährt
    - Optional kann mit Hilfe des 'Email Addon' noch eine Email-Nachricht abgesetzt werden.

##### Abschluß Konfiguration 'NUT-Client'
  Nach der Konfiguration die 'RaspberryMatic' per WebUI neu starten oder den 'NUT' Dienst mittels SSH und folgendem Kommando neustarten:
  ```
  /etc/init.d/S51nut restart
  ```
  Danach sollte der 'NUT' Daemon 'upsmon' laufen - die USV entsprechend überwachen und dann bei Ausfall des Stroms als Erstes eine Alarmmeldung innerhalb des HomeMatic-Systems generieren und bei zu langem Ausfall die RaspberryMatic automatisch geordnet herunterfahren.

  - Mit Hilfe der SSH-Konsole des 'NUT-Clients' kann man sich auch alle aktuellen Werte der USV des 'NUT-Servers' ausgeben lassen:
    ```
    upsc <UPSNAME>@<IP-ADRESS>
    ```
    |||
    | --- | --- |
    | \<UPSNAME\> |	Name des UPS-Devices des 'NUT-Servers' (z.B.: ups) |
    | \<IP-ADRESS\> | IP-Adresse des 'NUT-Servers' (z.B.: 192.168.10.114) oder 'localhost' |

    - Beispiel:
      ```
      upsc ups@localhost
      ```
      ```
      upsc ups@192.168.10.114  
      ```

  - Mit Hilfe der SSH-Konsole des 'NUT-Servers' kann man auch einen 'Shutdown'-Test für das gesamte 'NUT-System' durchführen – es wird ein Stromausfall mit einer leeren USV-Batterie simuliert, sodass der 'NUT-Server' den Herunterfahren Prozess startet:
    ```
    upsmon –c fsd
    ```

### Setup 'RaspberryMatic' als 'NUT-Server'

- Weiter zu: ['RaspberryMatic' - 'NUT-Server' - vollständige Konfigurationsdateien ...](./bin/RM_NUT_Server)

- Weiter zu: ['RaspberryMatic' - 'NUT'-Konfigurationsdateien (original) ...](./bin/RM_NUT_3.53.30)

### Historie
- 2022-04-18 - Erstveröffentlichung
