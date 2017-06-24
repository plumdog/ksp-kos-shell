declare function titlecase {
    declare parameter text.
    if not text {
        return "".
    }
    local words is text:split(" ").
    local cap_words is list().
    for word in words {
        cap_words:add(
            word:substring(0, 1):toupper()
            + word:substring(1, word:length - 1)).
    }
    return cap_words:join(" ").
}

declare function trimend {
    declare parameter text, endchar.

    if endchar:length = 0 {
        return text.
    }
    if endchar:length > 1 {
        set endchar to endchar[0].
    }

    if not text:endswith(endchar) {
        return text.
    }

    return trimend(text:substring(0, text:length - 1), endchar).
}

declare function string_repeat {
    declare parameter text, times.

    if times = 1 { return text. }
    if times = 2 { return text + text. }
    set half to floor(times / 2).
    set half_text to string_repeat(text, half).
    set out to half_text + half_text.
    if mod(times, 2) = 1 {
        set out to out + text.
    }
    return out.
}
