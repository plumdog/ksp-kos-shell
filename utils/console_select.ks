runpath("0:/utils/string.ks").

// Given a lexicon of options, print them to the terminal and request the user
// pick one. If `repeat` is true, then will keep prompting until a valid
// response is given, otherwise will just ask once.

// Always offers an "exit" option, in which case this will return false. Also
// returns false if no answer is given.

// If a valid option is selected, returns the key from the given lexicon.
declare function select {
    // A lexicon of options
    declare parameter options, repeat is true.

    local option_num is 0.
    local option_order is lexicon().

    print string_repeat("-", 20).

    for k in options:keys {
        set option_num to option_num + 1.
        option_order:add(option_num + "", k).
        print option_num + ". " + options[k].
    }
    print "x. Exit".

    set selected to terminal:input:getchar().

    print string_repeat("-", 20).

    if (selected = "x") {
        return false.
    } else if (option_order:haskey(selected)) {
        return option_order[selected].
    } else if repeat {
        print "Invalid selection".
        return select(options).
    } else {
        return false.
    }
}
