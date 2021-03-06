load("@rules_mono//dotnet/private:providers.bzl", "DotnetLibrary")
load("@rules_mono//dotnet/private:rules/versions.bzl", "compare_versions")

def collect_transitive_info(deps):
    """Collects transitive information.

    Args:
      deps: Dependencies that the DotnetLibrary depends on.

    Returns:
      list of DotnetLibrary.
    """

    # key: basename of result, value: DotnetLibrary
    lookup = {}

    basename = ""
    found = None

    for dep in deps:
        assembly = dep[DotnetLibrary]

        # Empty result is set for librarysets
        if assembly.result != None:
            basename = assembly.result.basename.lower()
            found = lookup.get(basename)
        else:
            basename = assembly.name.lower() + "__libraryset__"
            found = None

        if found == None or compare_versions(assembly.version, found.version) > 0:
            lookup[basename] = assembly
            if assembly.transitive != None:
                for t in assembly.transitive:
                    if t.result != None:
                        tbasename = t.result.basename.lower()
                        tfound = lookup.get(tbasename)
                    else:
                        tbasename = t.name.lower() + "__libraryset__"
                        tfound = None

                    if tfound == None or compare_versions(t.version, tfound.version) > 0:
                        lookup[tbasename] = t

    return lookup.values()
