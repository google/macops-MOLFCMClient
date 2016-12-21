/// Copyright 2015 Google Inc. All rights reserved.
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

#import "MOLFCMClient.h"

#import <MOLAuthenticatingURLSession.h>
#import <OCMock/OCMock.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <XCTest/XCTest.h>

/** MOLAuthenticatingURLSession testing extension. */
@interface MOLAuthenticatingURLSession(Testing)

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;

@end

/** MOLFCMClient testing extension. */
@interface MOLFCMClient(Testing)

- (void)processMessagesFromData:(NSData *)data;
- (void)log:(NSString *)log;
@property MOLAuthenticatingURLSession *authSession;
@property NSURLSession *session;

@end

@interface MOLFCMClientTests : XCTestCase

@property id sessionMock;

@end

@implementation MOLFCMClientTests

#pragma mark Test Setup

- (void)setUp {
  [super setUp];

  self.sessionMock = OCMClassMock([NSURLSession class]);
  OCMStub([self.sessionMock sessionWithConfiguration:[OCMArg any]
                                            delegate:[OCMArg any]
                                       delegateQueue:[OCMArg any]]).andReturn(self.sessionMock);
}

- (void)tearDown {
  [self.sessionMock stopMocking];
  self.sessionMock = nil;

  [super tearDown];
}


#pragma mark Test Helpers

/**
 *  Stub out dataTaskWithRequest:completionHandler:.
 *
 *  @param respData      The HTTP body to return
 *  @param resp          The NSHTTPURLResponse to return. If nil, a basic 200 response will be sent
 *  @param err           The error object to return to the handler
 *  @param validateBlock Use to validate the request is the one intended to be stubbed
 *                       Returning NO means this stub is not applied
 */
- (void)stubRequestBody:(NSData *)respData
               response:(NSURLResponse *)resp
                  error:(NSError *)err
          validateBlock:(BOOL(^)(NSURLRequest *req))validateBlock {
  if (!respData) respData = (NSData *)[NSNull null];
  if (!resp) resp = [self responseWithCode:200 headerDict:nil];
  if (!err) err = (NSError *)[NSNull null];

  // Cast the value into an NSURLRequest to save callers doing it.
  BOOL (^validateBlockWrapper)(id value) = ^BOOL(id value) {
    if (!validateBlock) return YES;
    NSURLRequest *req = (NSURLRequest *)value;
    return validateBlock(req);
  };

  OCMStub([self.sessionMock dataTaskWithRequest:[OCMArg checkWithBlock:validateBlockWrapper]
                              completionHandler:([OCMArg invokeBlockWithArgs:respData, resp, err,
                                                  nil])]);
}

/**
 *  Generate an NSHTTPURLResponse with the provided HTTP status code and header dictionary.
 *
 *  @param code       The HTTP status code for this response
 *  @param headerDict A dictionary of HTTP headers to add to the response
 *
 *  @return An initialized NSHTTPURLResponse.
 */
- (NSHTTPURLResponse *)responseWithCode:(NSInteger)code headerDict:(NSDictionary *)headerDict {
  return [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"a"]
                                     statusCode:code
                                    HTTPVersion:@"1.1"
                                   headerFields:headerDict];
}


#pragma mark MOLFCMClient Tests

- (void)testProcessMessagesFromData {
  MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                        sessionConfiguration:nil
                                              messageHandler:^(NSDictionary *message) {
                                               XCTAssertEqualObjects(message, @{});
                                             }];
  [fcm processMessagesFromData:[@"10 [[0,[{}]]]10 [[0,[{}]]]"
                                dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)testProcessMessagesFromNilData {
  MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                        sessionConfiguration:nil
                                              messageHandler:^(NSDictionary *message) {
                                               XCTFail();
                                             }];
  [fcm processMessagesFromData:nil];
}

- (void)testProcessMessagesFromOverIndexedData {
  MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                        sessionConfiguration:nil
                                              messageHandler:^(NSDictionary *message) {
                                               XCTFail();
                                             }];
  [fcm processMessagesFromData:[@"100 [[0,[{}]]]" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)testProcessMessagesFromMangledData {
  MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                        sessionConfiguration:nil
                                              messageHandler:^(NSDictionary *message) {
                                               XCTFail();
                                             }];
  [fcm processMessagesFromData:[@"~!@#$\0%^&*()_+=" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)testReadMessageSuccess {
  MOLAuthenticatingURLSession *session = [[MOLAuthenticatingURLSession alloc] init];
  MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                        sessionConfiguration:nil
                                              messageHandler:^(NSDictionary *message) {
                                               XCTAssertEqualObjects(message, @{});
                                             }];
  fcm.authSession = session;
  [fcm connect];
  [session URLSession:session.session
             dataTask:nil
       didReceiveData:[@"10 [[0,[{}]]]" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)testReadMessageFail {
  MOLAuthenticatingURLSession *session = [[MOLAuthenticatingURLSession alloc] init];
  MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                        sessionConfiguration:nil
                                              messageHandler:^(NSDictionary *message) {
                                               XCTFail();
                                             }];
  fcm.authSession = session;
  [fcm connect];
  [session URLSession:session.session
             dataTask:nil
       didReceiveData:[@"No Message" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)testAckMessage {
  MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                        sessionConfiguration:nil
                                              messageHandler:^(NSDictionary *message) {}];
  NSHTTPURLResponse *resp = [self responseWithCode:200 headerDict:nil];
  [self stubRequestBody:nil response:resp error:nil validateBlock:^BOOL(NSURLRequest *req) {
    return YES;
  }];
  fcm.acknowledgeErrorHandler = ^(NSDictionary *m, NSError *error) {
    XCTFail();
  };
  [fcm acknowledgeMessage:@{ @"message_id" : @"123" }];
}

- (void)testAckMessageFail {
  MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                        sessionConfiguration:nil
                                              messageHandler:^(NSDictionary *message) {}];
  NSHTTPURLResponse *resp = [self responseWithCode:500 headerDict:nil];
  NSError *err = [NSError errorWithDomain:@"com.google.corp.MOLNotificationsClient"
                                     code:-1
                                 userInfo:nil];
  [self stubRequestBody:nil response:resp error:err validateBlock:^BOOL(NSURLRequest *req) {
    return YES;
  }];
  fcm.acknowledgeErrorHandler = ^(NSDictionary *m, NSError *error) {
    XCTAssertEqualObjects(m, @{ @"message_id" : @"123" });
    XCTAssertEqual(error.code, -1);
  };
  [fcm acknowledgeMessage:@{ @"message_id" : @"123" }];
}

- (void)testDescription {
  MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                        sessionConfiguration:nil
                                              messageHandler:^(NSDictionary *message) {}];
  NSString *e = [NSString stringWithFormat:@"<MOLFCMClient: %p>\n"
                 @"bind: https://fcm.googleapis.com/fcm/connect/bind?token=123\n"
                 @"ack: https://fcm.googleapis.com/fcm/connect/ack", fcm];
  XCTAssertEqualObjects(fcm.description, e);
}

- (void)testLog {
  MOLFCMClient *fcm = [[MOLFCMClient alloc] initWithFCMToken:@"123"
                                        sessionConfiguration:nil
                                              messageHandler:^(NSDictionary *message) {}];
  fcm.loggingBlock = ^(NSString *log) {
    XCTAssertEqualObjects(log, @"test log");
  };
  [fcm log:@"test log"];
}

@end
