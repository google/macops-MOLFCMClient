# MOLFCMClient

A client for receiving and acknowledging FCM messages.

# Usage
```objc
#import <MOLFCMClient/MOLFCMClient.h>

MOLFCMClient *fcmClient = [[MOLFCMClient alloc] initWithFCMToken:token
                                            sessionConfiguration:configuration
                                                 messagesHandler:^(NSDictionary *message) {
  NSLog(@"%@", message);
  [fcmClient acknowledgeMessage:message];
}];
[fcmClient connect];
```

## Installation

#### Using CocoaPods

Add the following line to your Podfile:

```
pod 'MOLFCMClient'
```

#### Using [Bazel](http://bazel.build)

Add the following to your WORKSPACE:

```
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# Needed for MOLFCMClient
git_repository(
    name = "MOLCertificate",
    remote = "https://github.com/google/macops-molcertificate.git",
    tag = "v2.0",
)

# Needed for MOLFCMClient
git_repository(
    name = "MOLAuthenticatingURLSession",
    remote = "https://github.com/google/macops-molauthenticatingurlsession.git",
    tag = "v2.5",
)

git_repository(
    name = "MOLFCMClient",
    remote = "https://github.com/google/macops-molfmclient.git",
    tag = "v2.0",
)
```

And in your BUILD file, add MOLFCMClient as a dependency:

<pre>
objc_library(
    name = "MyAwesomeApp_lib",
    srcs = ["src/MyAwesomeApp.m", "src/MyAwesomeApp.h"],
    <strong>deps = ["@MOLFCMClient//:MOLFCMClient"],</strong>
)
</pre>

## Documentation

Reference documentation is at CocoaDocs.org:

http://cocoadocs.org/docsets/MOLFCMClient

## Contributing

Patches to this library are very much welcome.
Please see the [CONTRIBUTING](https://github.com/google/macops-molfcmclient/blob/master/CONTRIBUTING.md) file.

