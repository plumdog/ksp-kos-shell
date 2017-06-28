runpath("0:/utils/print.ks").

// Call this with a message to halt the program. Should only be used for
// non-recoverable errors.
declare function fatal_error {
    declare parameter text.
    print_alert(text).
    return 1/0.  // Arbitrary error to halt execution.
}
