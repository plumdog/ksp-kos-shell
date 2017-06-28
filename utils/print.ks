runpath("0:/utils/string.ks").

// Some standardisation for printing progress within a shell function.

declare function print_section {
    declare parameter text.
    print "# " + text + " #".
}

declare function print_info {
    declare parameter text.
    print " - " + text.
}

declare function print_alert {
    declare parameter text.
    set alert_marker to string_repeat("!", 4 + text:length).
    print alert_marker.
    print "! " + text + " !".
    print alert_marker.
}

declare function print_abort {
    declare parameter text.
    print_alert(text).
    print_alert("ABORTING").
}
