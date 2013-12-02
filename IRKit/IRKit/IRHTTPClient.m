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
#import "IRHTTPJSONOperation.h"

#define DEFAULT_TIMEOUT 25. // heroku timeout

@implementation IRHTTPClient

+ (NSURL*)base {
    return [NSURL URLWithString:@"http://api.getirkit.com"];
}

+ (void)createKeysWithCompletion: (void (^)(NSHTTPURLResponse *res, NSArray *keys, NSError *error))completion {
    [self post:@"/keys"
    withParams:nil
 targetNetwork:IRHTTPClientNetworkInternet
    completion:^(NSURLResponse *res, id data, NSError *error) {
        return completion((NSHTTPURLResponse*)res, data, error);
    }];
}

+ (void)waitForDoorWithKey: (NSString*)key
                completion: (void (^)(NSHTTPURLResponse*, id, NSError*))completion {
    [self post:@"/door"
    withParams:@{ @"key": key }
targetNetwork:IRHTTPClientNetworkInternet
    completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        LOG( @"res: %@, object: %@, error: %@", res, object, error );

        if (res && res.statusCode) {
            switch (res.statusCode) {
                case 200:
                    completion(res, object, nil);
                    break;
                case 408:
                    // retry
                    LOG( @"retrying" );
                    [self waitForDoorWithKey: key
                                  completion: completion];
                default:
                    break;
            }
            return;
        }
        if (error && (error.code == -1001) && ([error.domain isEqualToString:NSURLErrorDomain])) {
            // timeout -> retry
            LOG( @"retrying" );
            [self waitForDoorWithKey:key
                          completion:completion];
            return;
        }
        if (error) {
            completion(res, object, error);
            return;
        }
        // error object nil but error
        NSInteger code = (res && res.statusCode) ? res.statusCode
                                                 : IRKitHTTPStatusCodeUnknown;
        NSError* retError = [NSError errorWithDomain:IRKitErrorDomainHTTP
                                                code:code
                                            userInfo:nil];
        completion(res, object, retError);
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

    [IRHTTPJSONOperation sendRequest:request handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
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
