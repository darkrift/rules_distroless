"unit tests for dependency edges"

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//apt/private:dependency_edges.bzl", "direct_dependencies")

_TEST_SUITE_PREFIX = "dependency_edges/"

def _packages(closure):
    return {key: {"depends_on": depends_on} for key, depends_on in closure.items()}

def _transitive_reduction_test(ctx):
    env = unittest.begin(ctx)

    edges = direct_dependencies(_packages({
        "bash": ["libc6", "libtinfo6", "libgcc-s1"],
        "libtinfo6": ["libc6", "libgcc-s1"],
        "libc6": [],
        "libgcc-s1": ["libc6"],
    }))

    asserts.equals(env, ["libtinfo6"], edges["bash"])
    asserts.equals(env, ["libgcc-s1"], edges["libtinfo6"])
    asserts.equals(env, ["libc6"], edges["libgcc-s1"])
    asserts.equals(env, [], edges["libc6"])

    return unittest.end(env)

def _cycle_test(ctx):
    env = unittest.begin(ctx)

    edges = direct_dependencies(_packages({
        "libc6": ["libgcc-s1"],
        "libgcc-s1": ["libc6"],
        "bash": ["libc6", "libgcc-s1"],
    }))

    # Only one direction of a cycle is kept so the graph stays acyclic.
    asserts.equals(env, ["libgcc-s1"], edges["libc6"])
    asserts.equals(env, [], edges["libgcc-s1"])
    asserts.equals(env, ["libc6", "libgcc-s1"], edges["bash"])

    return unittest.end(env)

transitive_reduction_test = unittest.make(_transitive_reduction_test)
cycle_test = unittest.make(_cycle_test)

def dependency_edges_tests():
    transitive_reduction_test(name = _TEST_SUITE_PREFIX + "transitive_reduction")
    cycle_test(name = _TEST_SUITE_PREFIX + "cycle")
