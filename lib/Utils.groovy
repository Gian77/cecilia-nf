// Nextflow does not coerce `--flag false` / `--flag true` CLI overrides to a
// real Boolean — they arrive as the Strings "false"/"true", and Groovy treats
// any non-empty String (including "false") as truthy. Every boolean param must
// be passed through asBool() before an `if (params.x)`-style check, or
// `--x false` silently takes the true branch.
class Utils {
    static boolean asBool(v) {
        return (v instanceof String) ? v.toBoolean() : (v as boolean)
    }

    // A process output declared `path("*.fastq")` emits a bare Path when
    // exactly one file matches, and a List<Path> when more than one does.
    // Indexing a bare Path with [n] silently returns its n-th path *component*
    // (Path implements Iterable<Path>) instead of erroring — wrap any [n]
    // access on such an output in asList() first to get a real element.
    static List asList(v) {
        return (v instanceof List) ? v : [v]
    }
}
