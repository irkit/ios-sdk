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

#define LONGPOLL_TIMEOUT              25. // heroku timeout
#define DEFAULT_TIMEOUT               10. // short REST like requests
#define GETMESSAGES_LONGPOLL_INTERVAL 0.5 // don't ab agains IRKit

@interface IRHTTPClient ()

@property (nonatomic) NSURLRequest *longPollRequest;
@property (nonatomic) NSTimeInterval longPollInterval;

typedef BOOL (^ResponseHandlerBlock)(NSURLResponse *res, id object, NSError *error);
@property (nonatomic, copy) ResponseHandlerBlock longPollDidFinish;

@end

@implementation IRHTTPClient

- (void)dealloc {
    LOG_CURRENT_METHOD;
}

- (void)cancel {
    self.longPollRequest = nil;
}

#pragma mark - Private

- (void)startPollingRequest {
    LOG_CURRENT_METHOD;
    [IRHTTPJSONOperation sendRequest:self.longPollRequest
                            handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                if (! self.longPollRequest) {
                                    // cancelled
                                    return;
                                }
                                if (self.longPollDidFinish(response, object, error)) {
                                    return;
                                }
                                if (self.longPollInterval > 0) {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.longPollInterval * NSEC_PER_SEC),
                                                   dispatch_get_current_queue(), ^{
                                                       [self startPollingRequest];
                                                   });
                                }
                                else {
                                    [self startPollingRequest];
                                }
                            }];
}

#pragma mark - Class methods

+ (NSURL*)base {
    return [NSURL URLWithString:APIENDPOINT_BASE];
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

+ (NSError*)errorFromResponse: (NSHTTPURLResponse*)res {
    // error object nil but error
    NSInteger code = (res && res.statusCode) ? res.statusCode
                                             : IRKitHTTPStatusCodeUnknown;
    return [NSError errorWithDomain:IRKitErrorDomainHTTP
                               code:code
                           userInfo:nil];
}

+ (void)postSignal:(IRSignal *)signal withCompletion:(void (^)(NSError *))completion {
    NSMutableDictionary *payload = @{}.mutableCopy;
    payload[ @"freq" ] = signal.frequency;
    payload[ @"data" ] = signal.data;

    if (signal.peripheral.isReachableViaWifi) {
        [self postLocal:@"/messages"
             withParams:payload
               hostname:signal.peripheral.name
             completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
                 if (res && res.statusCode == 200) {
                     return completion( nil );
                 }
                 return completion( [self errorFromResponse:res] );
             }];
    }
    else {
        payload[ @"key" ] = signal.peripheral.key;
        [self postInternet:@"/messages"
                withParams:payload
           timeoutInterval:DEFAULT_TIMEOUT
                completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
                    if (res && res.statusCode == 200) {
                        return completion( nil );
                    }
                    return completion( [self errorFromResponse:res] );
                }];
    }
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

+ (IRHTTPClient*)waitForSignalFromHost: (NSString*)hostname
                        withCompletion: (void (^)(NSHTTPURLResponse* res, id object, NSError* error))completion {
    LOG_CURRENT_METHOD;
    NSURLRequest *req = [self makeGETLocalRequestToPath:@"/messages"
                                             withParams:nil
                                               hostname:hostname];
    IRHTTPClient *client = [[IRHTTPClient alloc] init];
    client.longPollRequest = req;
    client.longPollInterval = GETMESSAGES_LONGPOLL_INTERVAL;
    client.longPollDidFinish = (ResponseHandlerBlock)^(NSHTTPURLResponse *res, id object, NSError *error) {
        LOG( @"res: %@, object: %@, error: %@", res, object, error );

        if (res && res.statusCode) {
            switch (res.statusCode) {
                case 200:
                    if (object) {
                        completion(res, object, nil);
                        return YES;
                    }
                    // else, retry
                    return NO;
                default:
                    break;
            }
            // TODO sleep exponentially if unexpected error?
        }
        if (error && (error.code == -1001) && ([error.domain isEqualToString:NSURLErrorDomain])) {
            // timeout -> retry
            LOG( @"retrying" );
            // return NO;
            return YES; // for debug only, we should ignore this (it might happen too often...)
        }
        if (! error) {
            // custom error
            error = [self errorFromResponse:res];
        }
        completion(res, object, error);
        return YES; // stop if unexpected error
    };
    [client startPollingRequest];
    return client;
}

+ (IRHTTPClient*)waitForDoorWithKey: (NSString*)key
                         completion: (void (^)(NSHTTPURLResponse*, id, NSError*))completion {
    LOG_CURRENT_METHOD;
    NSURLRequest *req = [self makePOSTInternetRequestToPath:@"/door"
                                                 withParams:@{ @"key": key }
                                            timeoutInterval:LONGPOLL_TIMEOUT];
    IRHTTPClient *client = [[IRHTTPClient alloc] init];
    client.longPollRequest = req;
    client.longPollDidFinish = (ResponseHandlerBlock)^(NSHTTPURLResponse *res, id object, NSError *error) {
        LOG( @"res: %@, object: %@, error: %@", res, object, error );

        if (res && res.statusCode) {
            switch (res.statusCode) {
                case 200:
                    completion(res, object, nil);
                    return YES; // stop long polling
                case 408:
                    // retry
                    return NO;
                default:
                    break;
            }
            // TODO sleep exponentially if unexpected error?
            // retry
            return NO;
        }
        if (error && (error.code == -1001) && ([error.domain isEqualToString:NSURLErrorDomain])) {
            // timeout -> retry
            LOG( @"retrying" );
            return NO;
        }
        if (error) {
            completion(res, object, error);
            return YES; // stop if unexpected error
        }
        // error object nil but error
        completion(res, object, [self errorFromResponse:res]);
        return YES;
    };
    [client startPollingRequest];
    return client;
}

+ (void)cancelWaitForSignal {
    LOG_CURRENT_METHOD;

    [[ISHTTPOperationQueue defaultQueue] cancelOperationsWithPath:@"/messages"];
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

    NSURLRequest *req = [self makePOSTInternetRequestToPath:path
                                                 withParams:params
                                            timeoutInterval:timeout];

    [IRHTTPJSONOperation sendRequest:req handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
        if (! completion) {
            return;
        }
        // ISHTTPOperation calls our handler in main queue
        completion(response, object, error);
    }];
}

+ (NSURLRequest*)makePOSTInternetRequestToPath: (NSString*)path
                                    withParams: (NSDictionary*)params
                               timeoutInterval: (NSTimeInterval)timeout {
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

    return request;
}

+ (void)getLocal: (NSString*)path
      withParams: (NSDictionary*) params
        hostname: (NSString*)hostname
      completion: (void (^)(NSHTTPURLResponse *res, id object, NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSURLRequest *req = [self makeGETLocalRequestToPath:path
                                             withParams:params
                                               hostname:hostname];
    [IRHTTPJSONOperation sendRequest:req handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
        if (! completion) {
            return;
        }
        // ISHTTPOperation calls our handler in main queue
        completion(response, object, error);
    }];
}

+ (NSURLRequest*)makeGETLocalRequestToPath: (NSString*)path
                                withParams: (NSDictionary*)params
                                  hostname: (NSString*)hostname {
    NSString *query = [self stringOfURLEncodedDictionary:params];
    NSString *urlString;
    if (query) {
        urlString = [NSString stringWithFormat:@"http://%@.local%@?%@", hostname, path, query];
    }
    else {
        urlString = [NSString stringWithFormat:@"http://%@.local%@", hostname, path];
    }
    NSURL *url  = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = LONGPOLL_TIMEOUT;
    [request setHTTPMethod:@"GET"];
    return request;
}

+ (void)postLocal: (NSString*)path
       withParams: (NSDictionary*) params
         hostname: (NSString*)hostname
       completion: (void (^)(NSHTTPURLResponse *res, id object, NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSURLRequest *req = [self makePOSTLocalRequestToPath:path
                                              withParams:params
                                                hostname:hostname];

    [IRHTTPJSONOperation sendRequest:req handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
        if (! completion) {
            return;
        }
        // ISHTTPOperation calls our handler in main queue
        completion(response, object, error);
    }];
}

+ (NSURLRequest*)makePOSTLocalRequestToPath: (NSString*)path
                                 withParams: (NSDictionary*)params
                                   hostname: (NSString*)hostname {

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
    return request;
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
