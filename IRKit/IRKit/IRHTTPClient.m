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
#import "IRHTTPOperationQueue.h"
#import "Reachability.h"
#import "IRPersistentStore.h"
#import <CommonCrypto/CommonHMAC.h>

#define LONGPOLL_TIMEOUT              25. // heroku timeout
#define DEFAULT_TIMEOUT               10. // short REST like requests
#define GETMESSAGES_LONGPOLL_INTERVAL 0.5 // don't ab agains IRKit

static NSString *clientkey;

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

+ (void)fetchHostInfoOf: (NSString*)hostname withCompletion: (void (^)(NSHTTPURLResponse *res, NSDictionary *info, NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSURLRequest *req = [self makeGETRequestToLocalPath:@"/"
                                             withParams:nil
                                               hostname:hostname];
    [self issueLocalRequest:req completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        return completion((NSHTTPURLResponse*)res,
                          [self hostInfoFromResponse:res],
                          error);
    }];
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

+ (NSError*)errorFromResponse: (NSHTTPURLResponse*)res body:(id)object {
    // error object nil but error
    NSInteger code = (res && res.statusCode) ? res.statusCode
                                             : IRKitHTTPStatusCodeUnknown;
    if (code < 400) {
        // not an error
        return nil;
    }

    NSDictionary *userinfo;
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        userinfo = object;
    }
    return [NSError errorWithDomain:IRKitErrorDomainHTTP
                               code:code
                           userInfo:userinfo];
}

+ (void)postSignal:(IRSignal *)signal withCompletion:(void (^)(NSError *error))completion {
    NSMutableDictionary *payload = @{}.mutableCopy;
    payload[ @"freq" ]   = signal.frequency;
    payload[ @"data" ]   = signal.data;
    payload[ @"format" ] = signal.format;

    if (signal.peripheral.isReachableViaWifi) {
        NSURLRequest *request = [self makePOSTJSONRequestToLocalPath:@"/messages"
                                                          withParams:payload
                                                            hostname:signal.peripheral.hostname];
        [self issueLocalRequest:request completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
            return completion( error );
        }];
    }
    else {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:nil error:nil];
        NSString *json   = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSURLRequest *request = [self makePOSTRequestToInternetPath:@"/messages"
                                                         withParams:@{ @"message" : json,
                                                                       @"deviceid" : signal.peripheral.deviceid }
                                                    timeoutInterval:DEFAULT_TIMEOUT];
        [self issueInternetRequest:request completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
            return completion( error );
        }];
    }
}

+ (void)getDeviceIDFromHost: (NSString*)hostname withCompletion: (void (^)(NSHTTPURLResponse *res_local, NSHTTPURLResponse *res_internet, NSString *deviceid, NSError *error))completion {
    NSURLRequest *request = [self makePOSTRequestToLocalPath:@"/keys"
                                                  withParams:nil
                                                    hostname:hostname];
    [self issueLocalRequest:request completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        NSString *clienttoken = object[ @"clienttoken" ];
        if (! clienttoken) {
            return completion(res, nil, nil, error);
        }
        NSURLRequest *request2 = [self makePOSTRequestToInternetPath:@"/keys/add"
                                                          withParams:@{ @"clienttoken": clienttoken }
                                                     timeoutInterval:DEFAULT_TIMEOUT];
        [self issueInternetRequest:request2 completion:^(NSHTTPURLResponse *res2, id object2, NSError *error2) {
            NSString *deviceid = object2[ @"deviceid" ];
            return completion(res, res2, deviceid, error);
        }];
    }];
}

+ (void) ensureRegisteredAndCall: (void (^)(NSError *error))next {
    LOG_CURRENT_METHOD;

    if (! clientkey) {
        clientkey = [IRPersistentStore objectForKey:@"clientkey"];
    }
    if (! clientkey) {
        [IRHTTPClient registerWithCompletion:^(NSHTTPURLResponse *res, NSString *clientkey_, NSError *error) {
            if (error) {
                return next(error);
            }
            else if (! clientkey_) {
                // can't happen
                error = [NSError errorWithDomain:IRKitErrorDomainHTTP
                                            code:IRKitHTTPStatusCodeUnknown
                                        userInfo:nil];
                return next(error);
            }
            clientkey = clientkey_;
            [IRPersistentStore storeObject:clientkey forKey:@"clientkey"];
            LOG( @"successfully registered! clientkey: %@", clientkey );
            return next(nil);
        }];
        return;
    }
    next(nil);
}

+ (void)registerWithCompletion: (void (^)(NSHTTPURLResponse *res, NSString *clientkey, NSError *error))completion {
    NSString *uuid      = [[NSUUID UUID] UUIDString];
    NSString *signature = [[self signatureForString:uuid] uppercaseString];
    NSURLRequest *request = [self makePOSTRequestToInternetPath:@"/register"
                                                     withParams:@{
                                                                  @"randomid": uuid,
                                                                  @"signature": signature,
                                                                  }
                                                timeoutInterval:DEFAULT_TIMEOUT];
    [self issueInternetRequest:request completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        NSString *key;
        if ([object isKindOfClass:[NSDictionary class]]) {
            key = object[@"clientkey"];
        }
        return completion((NSHTTPURLResponse*)res,
                          key,
                          error);
    }];
}

+ (void)createKeysWithCompletion: (void (^)(NSHTTPURLResponse *res, NSDictionary *keys, NSError *error))completion {
    // POST /register should have been called before this, but let's make sure
    [self ensureRegisteredAndCall:^(NSError *error) {
        if (error) {
            return completion(nil,nil,error);
        }
        NSURLRequest *request = [self makePOSTRequestToInternetPath:@"/keys/new"
                                                         withParams:@{}
                                                    timeoutInterval:DEFAULT_TIMEOUT];
        [self issueInternetRequest:request completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
            return completion((NSHTTPURLResponse*)res,
                              object,
                              error);
        }];
    }];
}

+ (IRHTTPClient*)waitForSignalWithCompletion: (void (^)(NSHTTPURLResponse* res, IRSignal *signal, NSError* error))completion {
    LOG_CURRENT_METHOD;
    NSURLRequest *req = [self makeGETRequestToInternetPath:@"/messages"
                                                withParams:@{ @"clear": @"1" }
                                           timeoutInterval:LONGPOLL_TIMEOUT];
    IRHTTPClient *client = [[IRHTTPClient alloc] init];
    client.longPollRequest = req;
    client.longPollInterval = GETMESSAGES_LONGPOLL_INTERVAL;
    client.longPollDidFinish = (ResponseHandlerBlock)^(NSHTTPURLResponse *res, id object, NSError *error) {
        LOG( @"res: %@, object: %@, error: %@", res, object, error );

        bool doRetry = NO;
        if (res && res.statusCode) {
            switch (res.statusCode) {
                case 200:
                    if (object) {
                        IRSignal *signal = [[IRSignal alloc] initWithDictionary:object];
                        completion(res, signal, nil);
                        return YES;
                    }
                    // else, retry
                    doRetry = YES;
                    break;
                default:
                    break;
            }
            // TODO sleep exponentially if unexpected error?
        }
        if (error && (error.code == NSURLErrorTimedOut) && ([error.domain isEqualToString:NSURLErrorDomain])) {
            // -1001
            // timeout -> retry
            LOG( @"retrying" );
            doRetry = YES;
        }
        if (doRetry) {
            // remove clear=1
            client.longPollRequest = [self makeGETRequestToInternetPath:@"/messages"
                                                             withParams:@{}
                                                        timeoutInterval:LONGPOLL_TIMEOUT];
            return NO;
        }
        if (! error) {
            // custom error
            error = [self errorFromResponse:res body:object];
        }
        completion(res, object, error);
        return YES; // stop if unexpected error
    };
    [client startPollingRequest];
    return client;
}

+ (IRHTTPClient*)waitForDoorWithDeviceID: (NSString*)deviceid
                              completion: (void (^)(NSHTTPURLResponse*, id, NSError*))completion {
    LOG_CURRENT_METHOD;
    NSURLRequest *req = [self makePOSTRequestToInternetPath:@"/door"
                                                 withParams:@{ @"deviceid": deviceid }
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
        if (error && (error.code == NSURLErrorTimedOut) && ([error.domain isEqualToString:NSURLErrorDomain])) {
            // -1001
            // timeout -> retry
            LOG( @"retrying" );
            return NO;
        }
        if (error) {
            completion(res, object, error);
            return YES; // stop if unexpected error
        }
        // error object nil but error
        completion(res, object, [self errorFromResponse:res body:object]);
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

+ (void)loadImage:(NSString*)url
completionHandler:(void (^)(NSHTTPURLResponse *response, UIImage *image, NSError *error)) handler {
    LOG_CURRENT_METHOD;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
                               UIImage *ret;
                               if (! error) {
                                   ret = [UIImage imageWithData:data];
                               }
                               if (! handler) {
                                   return;
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   handler((NSHTTPURLResponse*)res,ret,error);
                               });
                           }];
}

+ (void)showAlertOfError:(NSError*)error {
    LOG( @"error: %@", error );
    if (! error) {
        return;
    }

    NSString *message = nil;
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        switch (error.code) {
            case NSURLErrorNotConnectedToInternet:
                // -1009
                message = IRLocalizedString(@"-1009 Please check your internet connection", @"-1009 error message");
                break;
            default:
                break;
        }
    }
    else if ([error.domain isEqualToString:IRKitErrorDomainHTTP]) {
        if (error.userInfo && error.userInfo[@"message"]) {
            message = error.userInfo[@"message"];
        }
        else {
            switch (error.code) {
                case 400:
                    message = IRLocalizedString(@"400 Invalid Request", @"http status code 400 error message");
                    break;
                case 401:
                    message = IRLocalizedString(@"401 Unauthorized", @"http status code 401 error message");
                    break;
                case 500:
                    message = IRLocalizedString(@"500 Something wrong, please try again, or contact us if problem persists", @"http status code 500 error message");
                    break;
                case 503:
                    message = IRLocalizedString(@"503 We're temporary under maintenance, please wait for a while and try again", @"http status code 503 error message");
                    break;
                default:
                    break;
            }
        }
    }

    [[[UIAlertView alloc] initWithTitle:message
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - Private

+ (void)issueLocalRequest:(NSURLRequest*)request
               completion:(void (^)(NSHTTPURLResponse *res, id object, NSError *error))completion {
    LOG(@"request: %@", request);

    [IRHTTPJSONOperation sendRequest:request
                               queue:[IRHTTPOperationQueue localQueue]
                             handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                 if (! completion) {
                                     return;
                                 }
                                 if (! error) {
                                     error = [self errorFromResponse:response body:object];
                                 }

                                 // ISHTTPOperation calls our handler in main queue
                                 completion(response, object, error);
                             }];
}

+ (void)issueInternetRequest:(NSURLRequest*)request
                  completion:(void (^)(NSHTTPURLResponse *res, id object, NSError *error))completion {
    LOG(@"request: %@", request);

    [IRHTTPJSONOperation sendRequest:request
                             handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                                 if (! completion) {
                                     return;
                                 }
                                 if (! error) {
                                     error = [self errorFromResponse:response body:object];
                                 }

                                 // if request was issued against server on internet,
                                 // alert about error
                                 [self showAlertOfError:error];

                                 // ISHTTPOperation calls our handler in main queue
                                 completion(response, object, error);
                             }];
}

+ (NSURLRequest*)makePOSTRequestToInternetPath: (NSString*)path
                                    withParams: (NSDictionary*)params
                               timeoutInterval: (NSTimeInterval)timeout {
    NSURL *url = [NSURL URLWithString:path relativeToURL:[self base]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = timeout;

    NSMutableDictionary *realParams = [params mutableCopy];
    realParams[ @"clientkey" ] = clientkey ? clientkey : [NSNull null];

    NSData *data = [[self stringOfURLEncodedDictionary:realParams] dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];

    return request;
}

+ (NSURLRequest*)makeGETRequestToInternetPath: (NSString*)path
                                   withParams: (NSDictionary*)params
                              timeoutInterval: (NSTimeInterval)timeout {

    NSMutableDictionary *realParams = [params mutableCopy];
    realParams[ @"clientkey" ] = clientkey ? clientkey : [NSNull null];

    NSString *query = [self stringOfURLEncodedDictionary:realParams];
    NSString *urlString;
    if (query) {
        urlString = [NSString stringWithFormat:@"%@%@?%@", [self base], path, query];
    }
    else {
        urlString = [NSString stringWithFormat:@"%@%@", [self base], path];
    }
    NSURL *url  = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = timeout;
    [request setHTTPMethod:@"GET"];
    return request;
}

+ (NSURLRequest*)makeGETRequestToLocalPath: (NSString*)path
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

+ (NSURLRequest*)makePOSTJSONRequestToLocalPath: (NSString*)path
                                     withParams: (NSDictionary*)params
                                       hostname: (NSString*)hostname {

    NSURL *base = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.local", hostname]];
    NSURL *url  = [NSURL URLWithString:path relativeToURL:base];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = DEFAULT_TIMEOUT;

    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:nil error:nil];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    return request;
}

+ (NSURLRequest*)makePOSTRequestToLocalPath: (NSString*)path
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
                                    if (params[key] == [NSNull null]) {
                                        return [NSString stringWithFormat:@"%@=", key];
                                    }
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

+ (NSString*)stringFromData:(NSData*)data {
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];

    if (!dataBuffer) {
        return [NSString string];
    }

    NSUInteger dataLength  = [data length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }

    return [NSString stringWithString:hexString];
}

+ (NSString*)signatureForString: (NSString*)string {
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    const char *cKey  = HMACKEY;
    const char *cData = [string cStringUsingEncoding:NSASCIIStringEncoding];

    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return [self stringFromData:HMAC];
}

@end
