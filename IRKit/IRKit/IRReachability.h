//
//  IRReachability.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/03/17.
//
//

#import <Foundation/Foundation.h>

@interface IRReachability : NSObject

+ (instancetype) reachabilityWithHostname: (NSString*)hostname;
- (BOOL)isReachableViaWiFi;
- (BOOL)isReachableViaWiFiAndDirect;

@end
