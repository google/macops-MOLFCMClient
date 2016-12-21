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

#import <Foundation/Foundation.h>

/**  A block that takes a NSDictionary object as an argument. */
typedef void (^MOLFCMMessageHandler)(NSDictionary *);

/**  A block that takes a NSError object as an argument. */
typedef void (^MOLFCMConnectionErrorHandler)(NSError *);

/**  A block that takes a NSDictionary and NSError object as arguments. */
typedef void (^MOLFCMAcknowledgeErrorHandler)(NSDictionary *, NSError *);

/**  A client for receiving and acknowledging Firebase Cloud Messaging (FCM) messages. */
@interface MOLFCMClient : NSObject

/**  Holds the FCM token */
@property(readonly, nonatomic) NSString *FCMToken;

/**  A block to be executed when there is an issue with acknowledging a message. */
@property(copy) MOLFCMAcknowledgeErrorHandler acknowledgeErrorHandler;

/**
 *  A block to be executed when there is a non-recoverable issue with the FCM Connection.
 *
 *  @note The following errors are handled:
 *          NSURLErrorTimedOut
 *          NSURLErrorCannotFindHost
 *          NSURLErrorCannotConnectToHost
 *          NSURLErrorNetworkConnectionLost
 *          NSURLErrorDNSLookupFailed
 *          NSURLErrorResourceUnavailable
 *          NSURLErrorNotConnectedToInternet
 *
 *  @note Any other errors will execute this block with the error as the parameter.
 */
@property(copy) MOLFCMConnectionErrorHandler connectionErrorHandler;

/**  If set, this block will be called with a string argument during certain debug events. */
@property(copy, nonatomic) void (^loggingBlock)(NSString *);

/**  Use initWithFCMToken:sessionConfiguration:messageHandler: */
- (instancetype)init NS_UNAVAILABLE;

/**
 *  The designated initializer.
 *
 *  @param FCMToken             FCM Token to identify and authenticate the client
 *  @param sessionConfiguration The desired NSURLSessionConfiguration, can be nil
 *  @param messageHandler      The block to be called for every message received
 *
 *  @note If the sessionConfiguration argument is nil, defaultSessionConfiguration will be used.
 *
 *  @return An initialized MOLFCMClient object
 */
- (instancetype)initWithFCMToken:(NSString *)FCMToken
            sessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration
                  messageHandler:(MOLFCMMessageHandler)messageHandler
                     NS_DESIGNATED_INITIALIZER;

/**
 *  Opens a connection to FCM and starts listening for messages.
 *
 *  @note If there is a failure in the connection, a thread will wait until FCM is reachable and
 *        try connecting again.
 */
- (void)connect;

/**
 *  Acknowledges a FCM message. Each message received must be acknowledged.
 *
 *  @param message A FCM message
 *
 *  @note Calls the acknowledgeErrorHandler block property when an acknowledge error occurs.
 */
- (void)acknowledgeMessage:(NSDictionary *)message;

/**  Closes all FCM connections. Stops Reachability. Outstanding tasks will be canceled. */
- (void)disconnect;

@end
