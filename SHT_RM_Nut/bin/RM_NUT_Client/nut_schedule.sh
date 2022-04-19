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
