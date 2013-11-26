//
//  IRHTTPClient.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/21.
//
//

#import <Foundation/Foundation.h>

NS_ENUM( uint8_t, IRHTTPClientNetwork ) {
    IRHTTPClientNetworkLocal    = 0,
    IRHTTPClientNetworkInternet = 1,
};

@interface IRHTTPClient : NSObject

+ (NSURL*)base;
+ (void)createKeysWithCompletion: (void (^)(NSHTTPURLResponse *res, NSArray *keys, NSError *error))completion;
+ (void)waitForDoorWithKey: (NSString*)key completion: (void (^)(NSHTTPURLResponse *res, NSError *error))completion;
+ (void)cancelWaitForDoor;

@end
