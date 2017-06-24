@LAZYGLOBAL OFF.

PRINT "Booting shell".


SAS OFF.

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").

RUNPATH("0:/shell.ks").