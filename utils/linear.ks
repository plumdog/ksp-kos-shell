set NULL to "__NULL__".

declare function linear {
    declare parameter x, x1, y1, x2, y2.

    set m to (y2 - y1) / (x2 - x1).
    set c to y1 - m * x1.

    return m * x + c.
}

declare function multilinear {
    // The x values of the given points must always increase.
    declare parameter x, points.

    set x0 to null.
    set y0 to null.
    set x1 to null.
    set y1 to null.

    for point in points {
        set x0 to x1.
        set y0 to y1.
        set x1 to point[0].
        set y1 to point[1].

        if not ((x0 = null) or (x1 = null)) {
            if (x >= x0) and (x <= x1) {
                return linear(x, x0, y0, x1, y1).
            }
        }
    }

    return false.
}
