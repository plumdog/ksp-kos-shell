PRINT "Preparing to launch...".
PRINT "Press enter to launch:".

set ch to terminal:input:ENTER. // terminal:input:getchar().

if ch = terminal:input:ENTER {
    RUNPATH("0:/launch/launch.ks").
    runlaunch().
} else {
    PRINT "Nothing to do.".
}