//
//  IRHTTPClient.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/21.
//
//

#import "Log.h"
#import "IRHTTPClient.h"
#import "IRHelper.h"
#import "ISHTTPOperation/ISHTTPOperation.h"
#import "IRConst.h"

#define DEFAULT_TIMEOUT 25. // heroku timeout

@implementation IRHTTPClient

+ (NSURL*)base {
    return [NSURL URLWithString:@"http://wifi-morse-setup.herokuapp.com"];
}

+ (void)createKeysWithCompletion: (void (^)(NSArray *keys, NSError *error))completion {
    [self post:@"/keys"
    withParams:nil
 targetNetwork:IRHTTPClientNetworkInternet
    completion:^(NSURLResponse *res, NSData *data, NSError *error) {
        if (error) {
            return completion( nil, error );
        }
        NSArray *object = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
        return completion( object, error );
    }];
}

+ (void)waitForDoorWithKey: (NSString*)key
                completion: (void (^)(NSError*))completion {
    LOG_CURRENT_METHOD;

    [self post:@"/door"
    withParams:@{ @"key": key }
targetNetwork:IRHTTPClientNetworkInternet
    completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        if (res && res.statusCode) {
            switch (res.statusCode) {
                case 200:
                    completion(nil);
                    break;
                case 408:
                    // retry
                    [self waitForDoorWithKey: key
                                  completion: completion];
                default:
                    break;
            }
            return;
        }
        if (error) {
            completion(error);
            return;
        }
        NSInteger code = (res && res.statusCode) ? res.statusCode
                                                 : IRKitHTTPStatusCodeUnknown;
        NSError* retError = [NSError errorWithDomain:IRKitErrorDomainHTTP
                                                code:code
                                            userInfo:nil];
        completion(retError);
    }];
}

+ (void)cancelWaitForDoor {
    LOG_CURRENT_METHOD;

    [[ISHTTPOperationQueue defaultQueue] cancelOperationsWithPath:@"/door"];
}

#pragma mark - Private

+ (void)post: (NSString*)path
  withParams: (NSDictionary*) params
targetNetwork: (enum IRHTTPClientNetwork)network
  completion: (void (^)(NSHTTPURLResponse*, id, NSError*))completion {
    LOG_CURRENT_METHOD;

    NSURL *url = [NSURL URLWithString:path relativeToURL:[self base]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = DEFAULT_TIMEOUT;

    NSData *data = [self dataOfURLEncodedDictionary:params];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];

    [ISHTTPOperation sendRequest:request handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
        if (! completion) {
            return;
        }
        // ISHTTPOperation calls our handler in main queue
        completion(response, object, error);
    }];
}

+ (NSData *)dataOfURLEncodedDictionary: (NSDictionary*)params {
    if ( ! params ) {
        return nil;
    }
    NSString *body = [[IRHelper mapObjects:params.allKeys
                               usingBlock:^id(id key, NSUInteger idx) {
                                   return [NSString stringWithFormat:@"%@=%@", key, [self URLEscapeString:params[key]]];
                               }] componentsJoinedByString:@"&"];
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*)URLEscapeString: (NSString*)string {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 kCFStringEncodingUTF8);
}

@end
