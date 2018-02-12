/// Copyright 2018 Google Inc. All rights reserved.
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///    http://www.apache.org/licenses/LICENSE-2.0
///
///    Unless required by applicable law or agreed to in writing, software
///    distributed under the License is distributed on an "AS IS" BASIS,
///    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///    See the License for the specific language governing permissions and
///    limitations under the License.

#import <Foundation/Foundation.h>

#import "MOLFCMClient.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    NSString *host = [[NSProcessInfo processInfo] arguments].lastObject;
    MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                                          host:host
                                               connectDelayMax:0
                                                    backoffMax:0
                                                    fatalCodes:nil
                                          sessionConfiguration:nil
                                                messageHandler:^(NSDictionary *m) {
      NSLog(@"%@", m);
    }];
    fcm.connectionErrorHandler = ^void(NSURLResponse *r, NSError *e) {
      NSLog(@"%@", e);
      NSLog(@"%@", r);
    };

    [fcm connect];
    NSLog(@"%@", fcm);
    [[NSRunLoop mainRunLoop] run];
  }
  return 0;
}
