runpath("0:/utils/string.ks").

// Given a directory, list the files. If abspath is true, absolute paths are
// returned, otherwise, they are paths relative to the given directory.
declare function list_paths {
    declare parameter dirpath.
    declare abspath is true.

    // Change to the given path, but remember the current directory so we can switch
    // back.
    local start_path is path().
    cd(dirpath).

    local found is list().
    list files in found.

    local paths is list().
    for f in found {
        paths:add(f:name).
    }

    cd(start_path).

    if abspath {
        set paths to append_dir(dirpath, paths).
    }
    return paths.
}

// Given a directory and a list of paths, append the directory to the start of the paths, handling "/" in the join.
declare function append_dir {
    declare parameter dirpath, paths_list.

    if not dirpath:endswith("/") {
        set dirpath to dirpath + "/".
    }

    local new_paths is list().

    for f in paths_list {
        new_paths:add(dirpath + f).
    }
    return new_paths.
}

// Given a path, find the last part of it. Eg, "my/path" becomes "path" and
// "my/directory/subdirectory/" becomes "subdirectory".
declare function basename {
    declare parameter path.

    set path to trimend(path, "/").

    if not path:contains("/") {
        return path.
    }

    local last_slash is path:findlast("/").
    return path:substring(last_slash + 1, path:length - last_slash - 1).
}
