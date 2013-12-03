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
#import "Reachability.h"

#define LONGPOLL_TIMEOUT 25. // heroku timeout
#define DEFAULT_TIMEOUT 5. // short REST like requests

@implementation IRHTTPClient

+ (NSURL*)base {
    return [NSURL URLWithString:@"http://api.getirkit.com"];
}

// from HTTP response Server header
// eg: "Server: IRKit/1.3.0.73.ge6e8514"
// "IRKit" is modelName
// "1.3.0.73.ge6e8514" is version
+ (NSDictionary*)hostInfoFromResponse: (NSHTTPURLResponse*)res {
    NSString* server = res.allHeaderFields[ @"Server" ];
    if (! server) {
        return nil;
    }
    NSArray* tmp = [server componentsSeparatedByString:@"/"];
    if (tmp.count != 2) {
        return nil;
    }
    return @{ @"modelName": tmp[ 0 ], @"version": tmp[ 1 ] };
}

+ (void)postSignal:(IRSignal *)signal withCompletion:(void (^)(NSError *))completion {
    NSMutableDictionary *payload = @{}.mutableCopy;
    payload[ @"freq" ] = [NSNumber numberWithUnsignedInteger:signal.frequency];
    payload[ @"data" ] = signal.data;
    if (! signal.peripheral.isInLocalNetwork) {
        payload[ @"key" ] = signal.peripheral.key;
    }

    [self postLocal:@"/messages"
         withParams:payload
           hostname:signal.hostname
         completion:^(NSHTTPURLResponse *res, id object, NSError *error) {

         }];
}

+ (void)getMessageFromHost: (NSString*)hostname withCompletion: (void (^)(NSHTTPURLResponse* res, NSDictionary* message, NSError* error))completion {
    [self getLocal:@"/messages"
        withParams:nil
          hostname:hostname
     completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
         completion(res, object, error);
     }];
}

+ (void)getKeyFromHost: (NSString*)hostname withCompletion: (void (^)(NSHTTPURLResponse*, NSString*, NSError*))completion {
    [self postLocal:@"/keys"
         withParams:nil
           hostname:hostname
    completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        return completion(res,
                          object ? object[ @"key" ] : nil,
                          error);
    }];
}

+ (void)createKeysWithCompletion: (void (^)(NSHTTPURLResponse *res, NSArray *keys, NSError *error))completion {
    [self postInternet:@"/keys"
            withParams:nil
       timeoutInterval:DEFAULT_TIMEOUT
            completion:^(NSURLResponse *res, id data, NSError *error) {
                return completion((NSHTTPURLResponse*)res,
                                  data ? data[ @"keys" ] : nil,
                                  error);
            }];
}

+ (void)waitForDoorWithKey: (NSString*)key
                completion: (void (^)(NSHTTPURLResponse*, id, NSError*))completion {
    [self postInternet:@"/door"
            withParams:@{ @"key": key }
       timeoutInterval:LONGPOLL_TIMEOUT
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

+ (void)postInternet: (NSString*)path
          withParams: (NSDictionary*) params
     timeoutInterval: (NSTimeInterval) timeout
          completion: (void (^)(NSHTTPURLResponse*, id, NSError*))completion {
    LOG_CURRENT_METHOD;

    NSURL *url = [NSURL URLWithString:path relativeToURL:[self base]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = timeout;

    NSData *data = [[self stringOfURLEncodedDictionary:params] dataUsingEncoding:NSUTF8StringEncoding];
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

+ (void)getLocal: (NSString*)path
      withParams: (NSDictionary*) params
        hostname: (NSString*)hostname
      completion: (void (^)(NSHTTPURLResponse *res, id object, NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSString *query = [self stringOfURLEncodedDictionary:params];
    NSString *urlString;
    if (query) {
        urlString = [NSString stringWithFormat:@"http://%@.local/%@?%@", hostname, path, query];
    }
    else {
        urlString = [NSString stringWithFormat:@"http://%@.local/%@", hostname, path];
    }
    NSURL *url  = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = DEFAULT_TIMEOUT;
    [request setHTTPMethod:@"GET"];

    [IRHTTPJSONOperation sendRequest:request handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
        if (! completion) {
            return;
        }
        // ISHTTPOperation calls our handler in main queue
        completion(response, object, error);
    }];
}

+ (void)postLocal: (NSString*)path
       withParams: (NSDictionary*) params
         hostname: (NSString*)hostname
       completion: (void (^)(NSHTTPURLResponse *res, id object, NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSURL *base = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.local", hostname]];
    NSURL *url  = [NSURL URLWithString:path relativeToURL:base];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = DEFAULT_TIMEOUT;

    NSData *data = [[self stringOfURLEncodedDictionary:params] dataUsingEncoding:NSUTF8StringEncoding];
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

+ (NSString*)stringOfURLEncodedDictionary: (NSDictionary*)params {
    if ( ! params ) {
        return nil;
    }
    NSString *body = [[IRHelper mapObjects:params.allKeys
                                usingBlock:^id(id key, NSUInteger idx) {
                                    return [NSString stringWithFormat:@"%@=%@", key, [self URLEscapeString:params[key]]];
                                }] componentsJoinedByString:@"&"];
    return body;
}

+ (NSString*)URLEscapeString: (NSString*)string {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 kCFStringEncodingUTF8);
}

@end
