//
//  IRHTTPClient.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/21.
//
//

#import <Foundation/Foundation.h>
#import "IRSignal.h"

NS_ENUM( uint8_t, IRHTTPClientNetwork ) {
    IRHTTPClientNetworkLocal    = 0,
    IRHTTPClientNetworkInternet = 1,
};

@interface IRHTTPClient : NSObject

+ (NSURL*)base;
+ (NSDictionary*)hostInfoFromResponse: (NSHTTPURLResponse*)res;
+ (void)postSignal: (IRSignal*)signal withCompletion: (void (^)(NSError *error))completion;
+ (void)getMessageFromHost: (NSString*)hostname withCompletion: (void (^)(NSHTTPURLResponse *res, NSDictionary *message, NSError *error))completion;
+ (void)getKeyFromHost: (NSString*)hostname withCompletion: (void (^)(NSHTTPURLResponse *res, NSString *key, NSError *error))completion;
+ (void)createKeysWithCompletion: (void (^)(NSHTTPURLResponse *res, NSArray *keys, NSError *error))completion;
+ (IRHTTPClient*)waitForDoorWithKey: (NSString*)key completion: (void (^)(NSHTTPURLResponse *res, id object, NSError *error))completion;
+ (void)cancelWaitForDoor;

@end
