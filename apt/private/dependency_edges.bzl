"""Direct package-to-package edges for dependency graphs such as SBOMs."""

def _closure(packages):
    return {
        key: {dependency: True for dependency in package["depends_on"] if dependency != key}
        for key, package in packages.items()
    }

def direct_dependencies(packages):
    """Computes an acyclic, transitively reduced set of dependency edges.

    The lockfile lists the whole transitive closure in `depends_on` of every
    package. Debian allows dependency cycles (e.g. `libc6` and `libgcc-s1`) but
    Bazel does not, so:

      * between packages of one cycle only the edges from the smaller package
        key to the larger one are kept, and
      * an edge is dropped when another dependency of the package already
        reaches the same package.

    Args:
      packages: dict of package key to a package with a transitive `depends_on`.

    Returns:
      A dict of package key to the sorted list of package keys it depends on.
    """
    closure = _closure(packages)

    edges = {}
    for key, dependencies in closure.items():
        covered = {}
        for via in dependencies:
            if key in closure.get(via, {}):
                continue
            for reached in closure.get(via, {}):
                if via not in closure.get(reached, {}):
                    covered[reached] = True

        kept = []
        for dependency in dependencies:
            if key in closure.get(dependency, {}):
                if key < dependency:
                    kept.append(dependency)
            elif dependency not in covered:
                kept.append(dependency)
        edges[key] = sorted(kept)
    return edges
