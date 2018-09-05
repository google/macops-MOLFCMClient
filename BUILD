load("@build_bazel_rules_apple//apple:macos.bzl",
     "macos_command_line_application",
     "macos_unit_test")

objc_library(
    name = "MOLFCMClient",
    srcs = ["Source/MOLFCMClient/MOLFCMClient.m"],
    hdrs = ["Source/MOLFCMClient/MOLFCMClient.h"],
    includes = ["Source"],
    sdk_frameworks = ["SystemConfiguration"],
    deps = ["@MOLAuthenticatingURLSession//:MOLAuthenticatingURLSession"],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "MOLFCMClientTestsLib",
    testonly = 1,
    srcs = ["Tests/MOLFCMClientTests.m"],
    deps = [
        ":MOLFCMClient",
        "@OCMock//:OCMock",
    ],
)

macos_unit_test(
    name = "MOLFCMClientTests",
    minimum_os_version = "10.9",
    deps = [":MOLFCMClientTestsLib"],
)
