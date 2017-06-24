runpath("0:/utils/print.ks").

declare function fatal_error {
    declare parameter text.
    print_alert(text).
    return 1/0.  // Arbitrary error to halt execution.
}
