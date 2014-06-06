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
#import "IRConst.h"
#import "IRHTTPJSONOperation.h"
#import "IRHTTPOperationQueue.h"
#import "IRKit.h"
#import "IRKit+Internal.h"
#import <CommonCrypto/CommonHMAC.h>

#define LONGPOLL_TIMEOUT              25. // heroku timeout
#define DEFAULT_TIMEOUT               10. // short REST like requests
#define IP_TIMEOUT                    1. // timeout for requests using IP directly, should not include WiFi connecting time
#define GETMESSAGES_LONGPOLL_INTERVAL 0.5 // don't ab agains IRKit
#define IRKIT_MODELNAME               @"IRKit"

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
    self.longPollDidFinish = nil;
    self.longPollRequest   = nil;
}

#pragma mark - Private

+ (NSString *)clientkey {
    return [IRKit sharedInstance].clientkey;
}

- (void)startPollingRequest {
    LOG_CURRENT_METHOD;
    if (!self.longPollRequest) {
        // cancelled
        return;
    }
    __weak typeof(self) _self = self;
    [IRHTTPJSONOperation sendRequest: self.longPollRequest
                             handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
        if (!_self.longPollRequest) {
            // cancelled
            return;
        }
        if (_self.longPollDidFinish && _self.longPollDidFinish(response, object, error)) {
            return;
        }
        if (_self.longPollInterval > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _self.longPollInterval * NSEC_PER_SEC),
                           dispatch_get_main_queue(), ^{
                [_self startPollingRequest];
            });
        }
        else {
            [_self startPollingRequest];
        }
    }];
}

#pragma mark - Class methods

+ (NSURL *)base {
    return [NSURL URLWithString: APIENDPOINT_BASE];
}

+ (void)fetchHostInfoOf:(NSString *)hostname withCompletion:(void (^)(NSHTTPURLResponse *res, NSDictionary *info, NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSURLRequest *req = [self makeGETRequestToLocalPath: @"/"
                                             withParams: nil
                                               hostname: hostname];
    [self issueLocalRequest: req completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        return completion((NSHTTPURLResponse *)res,
                          [self hostInfoFromResponse: res],
                          error);
    }];
}

// from HTTP response Server header
// eg: "Server: IRKit/1.3.0.73.ge6e8514"
// "IRKit" is modelName
// "1.3.0.73.ge6e8514" is version
+ (NSDictionary *)hostInfoFromResponse:(NSHTTPURLResponse *)res {
    NSString *server = res.allHeaderFields[ @"Server" ];

    if (!server) {
        return nil;
    }
    NSArray *tmp = [server componentsSeparatedByString: @"/"];
    if (tmp.count != 2) {
        return nil;
    }
    return @{ @"modelName": tmp[ 0 ], @"version": tmp[ 1 ] };
}

+ (void)checkIfAdhocWithCompletion:(void (^)(NSHTTPURLResponse *res, BOOL isAdhoc, NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSURLRequest *req = [self makeGETRequestToIP: @"192.168.1.1" path: @"/"];
    [self issueLocalRequest: req completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        NSDictionary *info = [self hostInfoFromResponse: res];
        completion(res,
                   [info[@"modelName"] isEqualToString: IRKIT_MODELNAME],
                   error);
    }];
}

+ (void)postWifiKeys:(NSString *)keys withCompletion:(void (^)(NSHTTPURLResponse *res, id body, NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSURLRequest *req = [self makePOSTRequestToIP: @"192.168.1.1" path: @"/wifi" body: keys];
    [self issueLocalRequest: req completion: completion];
}

+ (NSError *)errorFromResponse:(NSHTTPURLResponse *)res body:(id)object {
    // error object nil but error
    NSInteger code = (res && res.statusCode) ? res.statusCode
                     : IRKitHTTPStatusCodeUnknown;

    if (code < 400) {
        // not an error
        return nil;
    }

    NSDictionary *userinfo;
    if (object && [object isKindOfClass: [NSDictionary class]]) {
        userinfo = object;
    }
    return [NSError errorWithDomain: IRKitErrorDomainHTTP
                               code: code
                           userInfo: userinfo];
}

+ (void)postSignal:(IRSignal *)signal withCompletion:(void (^)(NSError *error))completion {
    NSAssert(signal.peripheral, @"call this when you have signal.peripheral set, otherwise use postSignal:toPeripheral:withCompletion:");
    [self postSignal: signal toPeripheral: signal.peripheral withCompletion: completion];
}

+ (void)postSignal:(IRSignal *)signal toPeripheral:(IRPeripheral*)peripheral withCompletion:(void (^)(NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSMutableDictionary *payload = @{}.mutableCopy;
    payload[ @"freq" ]   = signal.frequency;
    payload[ @"data" ]   = signal.data;
    payload[ @"format" ] = signal.format;

    if (peripheral.isReachableViaWifi) {
        LOG(@"via wifi");
        NSURLRequest *request = [self makePOSTJSONRequestToLocalPath: @"/messages"
                                                          withParams: payload
                                                            hostname: peripheral.hostname];
        [self issueLocalRequest: request completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
            return completion(error);
        }];
    }
    else {
        LOG(@"via internet");
        NSData *jsonData      = [NSJSONSerialization dataWithJSONObject: payload options: 0 error: nil];
        NSString *json        = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
        NSURLRequest *request = [self makePOSTRequestToInternetPath: @"/1/messages"
                                                         withParams: @{ @"message" : json,
                                                                        @"deviceid" : peripheral.deviceid }
                                                    timeoutInterval: DEFAULT_TIMEOUT];
        [self issueInternetRequest: request completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
            return completion(error);
        }];
    }
}

+ (void)getDeviceIDFromHost:(NSString *)hostname withCompletion:(void (^)(NSHTTPURLResponse *res_local, NSHTTPURLResponse *res_internet, NSString *deviceid, NSError *error))completion {
    NSURLRequest *request = [self makePOSTRequestToLocalPath: @"/keys"
                                                  withParams: nil
                                                    hostname: hostname];

    [self issueLocalRequest: request completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        NSString *clienttoken = object[ @"clienttoken" ];
        if (!clienttoken) {
            return completion(res, nil, nil, error);
        }
        NSURLRequest *request2 = [self makePOSTRequestToInternetPath: @"/1/keys"
                                                          withParams: @{ @"clienttoken": clienttoken }
                                                     timeoutInterval: DEFAULT_TIMEOUT];
        [self issueInternetRequest: request2 completion:^(NSHTTPURLResponse *res2, id object2, NSError *error2) {
            NSString *deviceid = object2[ @"deviceid" ];
            return completion(res, res2, deviceid, error);
        }];
    }];
}

+ (void)ensureRegisteredAndCall:(void (^)(NSError *error))next {
    LOG_CURRENT_METHOD;

    if (![self clientkey]) {
        [IRHTTPClient registerClientWithCompletion:^(NSHTTPURLResponse *res, NSString *clientkey_, NSError *error) {
            if (error) {
                return next(error);
            }
            else if (!clientkey_) {
                // can't happen
                error = [NSError errorWithDomain: IRKitErrorDomainHTTP
                                            code: IRKitHTTPStatusCodeUnknown
                                        userInfo: nil];
                next(error);
                return;
            }
            [[IRKit sharedInstance] setClientkey: clientkey_];
            LOG(@"successfully registered! clientkey: %@", clientkey_);
            next(nil);
            return;
        }];
        return;
    }
    next(nil);
}

+ (void)registerClientWithCompletion:(void (^)(NSHTTPURLResponse *res, NSString *clientkey, NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSString *apikey = [IRKit sharedInstance].apikey;
    if (!apikey) {
        IRKitLog(@"call \"[IRKit startWithAPIKey:] first!\nPlease read http://getirkit.com/ to get an API Key\"");
        abort();
    }

    NSURLRequest *request = [self makePOSTRequestToInternetPath: @"/1/clients"
                                                     withParams: @{
                                 @"apikey": apikey,
                             }
                                                timeoutInterval: DEFAULT_TIMEOUT];
    [self issueInternetRequest: request completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        NSString *key;
        if ([object isKindOfClass: [NSDictionary class]]) {
            key = object[@"clientkey"];
        }
        return completion((NSHTTPURLResponse *)res,
                          key,
                          error);
    }];
}

+ (void)registerDeviceWithCompletion:(void (^)(NSHTTPURLResponse *res, NSDictionary *keys, NSError *error))completion {
    // POST /1/clients should have been called before this, but let's make sure
    [self ensureRegisteredAndCall:^(NSError *error) {
        if (error) {
            return completion(nil, nil, error);
        }
        NSURLRequest *request = [self makePOSTRequestToInternetPath: @"/1/devices"
                                                         withParams: @{}
                                                    timeoutInterval: DEFAULT_TIMEOUT];
        [self issueInternetRequest: request completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
            return completion((NSHTTPURLResponse *)res,
                              object,
                              error);
        }];
    }];
}

+ (IRHTTPClient *)waitForSignalWithCompletion:(void (^)(NSHTTPURLResponse *res, IRSignal *signal, NSError *error))completion {
    LOG_CURRENT_METHOD;
    NSURLRequest *req = [self makeGETRequestToInternetPath: @"/1/messages"
                                                withParams: @{ @"clear": @"1" }
                                           timeoutInterval: LONGPOLL_TIMEOUT];
    IRHTTPClient *client = [[IRHTTPClient alloc] init];
    client.longPollRequest  = req;
    client.longPollInterval = GETMESSAGES_LONGPOLL_INTERVAL;
    __weak IRHTTPClient *_client = client;
    client.longPollDidFinish = (ResponseHandlerBlock) ^ (NSHTTPURLResponse * res, id object, NSError * error) {
        LOG(@"res: %@, object: %@, error: %@", res, object, error);

        bool doRetry = NO;
        if (res && res.statusCode) {
            switch (res.statusCode) {
            case 200:
                if (object) {
                    IRSignal *signal = [[IRSignal alloc] initWithDictionary: object];
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
        if (error && (error.code == NSURLErrorTimedOut) && ([error.domain isEqualToString: NSURLErrorDomain])) {
            // -1001
            // timeout -> retry
            LOG(@"retrying");
            doRetry = YES;
        }
        if (doRetry) {
            // remove clear=1
            _client.longPollRequest = [self makeGETRequestToInternetPath: @"/1/messages"
                                                              withParams: @{}
                                                         timeoutInterval: LONGPOLL_TIMEOUT];
            return NO;
        }
        if (!error) {
            // custom error
            error = [self errorFromResponse: res body: object];
        }
        completion(res, object, error);
        return YES; // stop if unexpected error
    };
    [client startPollingRequest];
    return client;
}

+ (IRHTTPClient *)waitForDoorWithDeviceID:(NSString *)deviceid
                               completion:(void (^)(NSHTTPURLResponse *, id, NSError *))completion {
    LOG_CURRENT_METHOD;
    NSURLRequest *req = [self makePOSTRequestToInternetPath: @"/1/door"
                                                 withParams: @{ @"deviceid": deviceid ? deviceid : @"" }
                                            timeoutInterval: LONGPOLL_TIMEOUT];
    IRHTTPClient *client = [[IRHTTPClient alloc] init];
    client.longPollRequest   = req;
    client.longPollDidFinish = (ResponseHandlerBlock) ^ (NSHTTPURLResponse * res, id object, NSError * error) {
        LOG(@"res: %@, object: %@, error: %@", res, object, error);

        if (res && res.statusCode) {
            switch (res.statusCode) {
            case 200:
                completion(res, object, nil);
                return YES;         // stop long polling

            case 400:
                // must be a bug (or from IRKitViewSamples)
                completion(res, object, [self errorFromResponse: res body: object]);
                return YES;

            case 401:
                // session expired
                completion(res, object, [self errorFromResponse: res body: object]);
                return YES;

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
        if (error && (error.code == NSURLErrorTimedOut) && ([error.domain isEqualToString: NSURLErrorDomain])) {
            // -1001
            // timeout -> retry
            LOG(@"retrying");
            return NO;
        }
        if (error) {
            completion(res, object, error);
            return YES; // stop if unexpected error
        }
        // error object nil but error
        completion(res, object, [self errorFromResponse: res body: object]);
        return YES;
    };
    [client startPollingRequest];
    return client;
}

+ (void)showAlertOfError:(NSError *)error {
    LOG(@"error: %@", error);
    if (!error) {
        return;
    }

    NSString *message = nil;
    if ([error.domain isEqualToString: NSURLErrorDomain]) {
        switch (error.code) {
        case NSURLErrorNotConnectedToInternet:
            // -1009
            message = IRLocalizedString(@"-1009 Please check your internet connection", @"-1009 error message");
            break;
        case NSURLErrorTimedOut:
            // -1001
            message = IRLocalizedString(@"-1001 Please check your internet connection", @"-1001 error message");
            break;
        default:
            break;
        }
    }
    else if ([error.domain isEqualToString: IRKitErrorDomainHTTP]) {
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

    if (message) {
#if TARGET_OS_IPHONE
        [[[UIAlertView alloc] initWithTitle: message
                                    message: nil
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
#endif
    }
}

+ (void)cancelLocalRequests {
    LOG_CURRENT_METHOD;
    [[IRHTTPOperationQueue localQueue] cancelAllOperations];
}

#pragma mark - Private

+ (void)issueLocalRequest:(NSURLRequest *)request
               completion:(void (^)(NSHTTPURLResponse *res, id object, NSError *error))completion {
    LOG(@"request: %@", request);

    [IRHTTPJSONOperation sendRequest: request
                               queue: [IRHTTPOperationQueue localQueue]
                             handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
        if (!completion) {
            return;
        }
        if (!error) {
            error = [self errorFromResponse: response body: object];
        }

        // IRHTTPOperation calls our handler in main queue
        completion(response, object, error);
    }];
}

+ (void)issueInternetRequest:(NSURLRequest *)request
                  completion:(void (^)(NSHTTPURLResponse *res, id object, NSError *error))completion {
    LOG(@"request: %@", request);

    [IRHTTPJSONOperation sendRequest: request
                             handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
        if (!completion) {
            return;
        }
        if (!error) {
            error = [self errorFromResponse: response body: object];
        }

        // if request was issued against server on internet,
        // alert about error
        [self showAlertOfError: error];

        // IRHTTPOperation calls our handler in main queue
        completion(response, object, error);
    }];
}

+ (NSURLRequest *)makePOSTRequestToInternetPath:(NSString *)path
                                     withParams:(NSDictionary *)params
                                timeoutInterval:(NSTimeInterval)timeout {
    NSURL *url                   = [NSURL URLWithString: path relativeToURL: [self base]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = timeout;

    NSMutableDictionary *realParams = [params mutableCopy];
    NSString *clientkey             = [self clientkey];
    realParams[ @"clientkey" ] = clientkey ? clientkey : [NSNull null];

    NSData *data = [[self stringOfURLEncodedDictionary: realParams] dataUsingEncoding: NSUTF8StringEncoding];
    [request setHTTPMethod: @"POST"];
    [request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    [request setValue: [NSString stringWithFormat: @"%lu", (unsigned long)[data length]] forHTTPHeaderField: @"Content-Length"];
    [request setHTTPBody: data];

    return request;
}

+ (NSURLRequest *)makeGETRequestToInternetPath:(NSString *)path
                                    withParams:(NSDictionary *)params
                               timeoutInterval:(NSTimeInterval)timeout {
    NSMutableDictionary *realParams = [params mutableCopy];
    NSString *clientkey             = [self clientkey];

    realParams[ @"clientkey" ] = clientkey ? clientkey : [NSNull null];

    NSString *query = [self stringOfURLEncodedDictionary: realParams];
    NSString *urlString;
    if (query) {
        urlString = [NSString stringWithFormat: @"%@%@?%@", [self base], path, query];
    }
    else {
        urlString = [NSString stringWithFormat: @"%@%@", [self base], path];
    }
    NSURL *url = [NSURL URLWithString: urlString];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = timeout;
    [request setHTTPMethod: @"GET"];
    return request;
}

+ (NSURLRequest *)makeGETRequestToLocalPath:(NSString *)path
                                 withParams:(NSDictionary *)params
                                   hostname:(NSString *)hostname {
    NSString *query = [self stringOfURLEncodedDictionary: params];
    NSString *urlString;

    if (query) {
        urlString = [NSString stringWithFormat: @"http://%@.local%@?%@", hostname, path, query];
    }
    else {
        urlString = [NSString stringWithFormat: @"http://%@.local%@", hostname, path];
    }
    NSURL *url                   = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = LONGPOLL_TIMEOUT;
    [request setHTTPMethod: @"GET"];
    return request;
}

+ (NSURLRequest *)makeGETRequestToIP:(NSString *)ip
                                path:(NSString *)path {
    NSString *urlString          = [NSString stringWithFormat: @"http://%@%@", ip, path];
    NSURL *url                   = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = IP_TIMEOUT;
    [request setHTTPMethod: @"GET"];
    return request;
}

+ (NSURLRequest *)makePOSTRequestToIP:(NSString *)ip
                                 path:(NSString *)path
                                 body:(NSString *)body {
    NSString *urlString          = [NSString stringWithFormat: @"http://%@%@", ip, path];
    NSURL *url                   = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = IP_TIMEOUT;

    NSData *data = [body dataUsingEncoding: NSUTF8StringEncoding];
    [request setHTTPMethod: @"POST"];
    [request setValue: @"text/plain" forHTTPHeaderField: @"Content-Type"];
    [request setValue: [NSString stringWithFormat: @"%lu", (unsigned long)[data length]] forHTTPHeaderField: @"Content-Length"];
    [request setHTTPBody: data];
    return request;
}

+ (NSURLRequest *)makePOSTJSONRequestToLocalPath:(NSString *)path
                                      withParams:(NSDictionary *)params
                                        hostname:(NSString *)hostname {
    NSURL *base                  = [NSURL URLWithString: [NSString stringWithFormat: @"http://%@.local", hostname]];
    NSURL *url                   = [NSURL URLWithString: path relativeToURL: base];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = DEFAULT_TIMEOUT;

    NSData *data = [NSJSONSerialization dataWithJSONObject: params options: 0 error: nil];
    [request setHTTPMethod: @"POST"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    [request setValue: [NSString stringWithFormat: @"%lu", (unsigned long)[data length]] forHTTPHeaderField: @"Content-Length"];
    [request setHTTPBody: data];
    return request;
}

+ (NSURLRequest *)makePOSTRequestToLocalPath:(NSString *)path
                                  withParams:(NSDictionary *)params
                                    hostname:(NSString *)hostname {
    NSURL *base                  = [NSURL URLWithString: [NSString stringWithFormat: @"http://%@.local", hostname]];
    NSURL *url                   = [NSURL URLWithString: path relativeToURL: base];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    request.URL             = url;
    request.cachePolicy     = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = DEFAULT_TIMEOUT;

    NSData *data = [[self stringOfURLEncodedDictionary: params] dataUsingEncoding: NSUTF8StringEncoding];
    [request setHTTPMethod: @"POST"];
    [request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    [request setValue: [NSString stringWithFormat: @"%lu", (unsigned long)[data length]] forHTTPHeaderField: @"Content-Length"];
    [request setHTTPBody: data];
    return request;
}

+ (NSString *)stringOfURLEncodedDictionary:(NSDictionary *)params {
    if (!params) {
        return nil;
    }
    NSString *body = [[IRHelper mapObjects: params.allKeys
                                usingBlock:^id (id key, NSUInteger idx) {
        if (params[key] == [NSNull null]) {
            return [NSString stringWithFormat: @"%@=", key];
        }
        return [NSString stringWithFormat: @"%@=%@", key, [self URLEscapeString: params[key]]];
    }] componentsJoinedByString: @"&"];
    return body;
}

+ (NSString *)URLEscapeString:(NSString *)string {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 kCFStringEncodingUTF8);
}

@end
