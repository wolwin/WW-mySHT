#!/bin/tclsh

# Simple tclsh script to write state to an <internal> variable.
# 
# Usage:
# Msg2Var.tcl <msg> <var>
#
# <msg> = message text
# <var> = system variable name
#
# Return 0 - success
#        1 - error

load tclrpc.so
load tclrega.so

if { $argc != 2 } {
  puts "ERROR: Msg2Var [msg] [var] - script requires two arguments"
  exit 1
}

set msg [lindex $argv 0]
set var [lindex $argv 1]

  set script "
    object alObj = null;
    string sSysVarId;
    foreach(sSysVarId, dom.GetObject(ID_SYSTEM_VARIABLES).EnumIDs()) {
      object oSysVar = dom.GetObject(sSysVarId);
      if(oSysVar.Name() == \"$var\") {
        alObj=oSysVar;
        break;
      }
    }
  "
  
append script "

  if(alObj != null) {
    alObj.State(\"$msg\");
  }
"  

if { ![catch {array set result [rega_script $script]}] } then {
  if { $result(alObj) != "null" } {
    set res 0
  } else {
    set res 1
  }
} else {
  set res 1
}

exit $res
