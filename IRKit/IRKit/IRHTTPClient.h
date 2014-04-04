//
//  IRHTTPClient.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/21.
//
//

#import <Foundation/Foundation.h>
#import "IRSignal.h"

@interface IRHTTPClient : NSObject

- (void)cancel;
+ (NSURL *)base;
+ (void)fetchHostInfoOf:(NSString *)hostname withCompletion:(void (^) (NSHTTPURLResponse * res, NSDictionary * info, NSError * error))completion;
+ (NSDictionary *)hostInfoFromResponse:(NSHTTPURLResponse *)res;
+ (void)checkIfAdhocWithCompletion:(void (^) (NSHTTPURLResponse * res, BOOL isAdhoc, NSError * error))completion;
+ (void)postWifiKeys:(NSString *)keys withCompletion:(void (^) (NSHTTPURLResponse * res, id body, NSError * error))completion;
+ (void)postSignal:(IRSignal *)signal withCompletion:(void (^) (NSError * error))completion;
+ (void)postSignal:(IRSignal *)signal toPeripheral:(IRPeripheral*)peripheral withCompletion:(void (^)(NSError *error))completion;
+ (void)getDeviceIDFromHost:(NSString *)hostname withCompletion:(void (^) (NSHTTPURLResponse * res_local, NSHTTPURLResponse * res_internet, NSString * deviceid, NSError * error))completion;
+ (void)ensureRegisteredAndCall:(void (^) (NSError * error))next;
+ (void)registerDeviceWithCompletion:(void (^) (NSHTTPURLResponse * res, NSDictionary * keys, NSError * error))completion;
+ (IRHTTPClient *)waitForSignalWithCompletion:(void (^) (NSHTTPURLResponse * res, IRSignal * signal, NSError * error))completion;
+ (IRHTTPClient *)waitForDoorWithDeviceID:(NSString *)deviceid completion:(void (^) (NSHTTPURLResponse * res, id object, NSError * error))completion;
+ (void)showAlertOfError:(NSError *)error;
+ (void)cancelLocalRequests;

@end
