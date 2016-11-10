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

Install using CocoaPods.

```
pod 'MOLFCMClient'
```

## Documentation

Reference documentation is at CocoaDocs.org:

http://cocoadocs.org/docsets/MOLFCMClient

## Contributing

Patches to this library are very much welcome.
Please see the [CONTRIBUTING](https://github.com/google/macops-molfcmclient/blob/master/CONTRIBUTING.md) file.

