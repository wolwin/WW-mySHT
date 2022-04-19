#!/bin/sh
#
# This script will be called as soon as NUT identifies a
# connected UPS system to require some attention.
#
# You can adapt this to your needs and use ${UPSNAME} and
# ${NOTIFYTYPE} which will be set by NUT.
#

myMsg=$*
myMsg="NUT-Meldung von [`hostname`]: ${NOTIFYTYPE}\n\n${myMsg}"

# trigger a HomeMatic alarm message to "${UPSNAME}-Alarm"
/bin/triggerAlarm.tcl "${NOTIFYTYPE}" "${UPSNAME}-Alarm"

# trigger an email alarm message via template
SCRIPTPATH=$(cd `dirname $0` && pwd)
"$SCRIPTPATH/Msg2Var.tcl" "16" "sv_EM-SUBJ-PRE"
"$SCRIPTPATH/Msg2Var.tcl" "${NOTIFYTYPE}" "sv_EM-SUBJ"
"$SCRIPTPATH/Msg2Var.tcl" "${myMsg}" "sv_EM-TEXT"
"/etc/config/addons/email/email" "41"
