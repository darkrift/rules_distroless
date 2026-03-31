"deb_import"

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# BUILD.bazel template
_DEB_IMPORT_BUILD_TMPL = '''
load("@rules_distroless//apt/private:deb_postfix.bzl", "deb_postfix")
load("@package_metadata//rules:package_metadata.bzl", "package_metadata")

package_metadata(
    name = "package_metadata",
    purl = {purl},
    visibility = ["//visibility:public"],
)

deb_postfix(
    name = "data",
    srcs = glob(["data.tar*"]),
    outs = ["layer.tar.gz"],
    mergedusr = {mergedusr},

    visibility = ["//visibility:public"],
    package_metadata = [
        ":package_metadata",
    ],
)

filegroup(
    name = "control",
    srcs = glob(["control.tar.*"]),
    visibility = ["//visibility:public"],
)
'''

def deb_import(mergedusr = False, purl = None, **kwargs):
    http_archive(
        build_file_content = _DEB_IMPORT_BUILD_TMPL.format(
            mergedusr = mergedusr,
            purl = repr(purl),
        ),
        **kwargs
    )
