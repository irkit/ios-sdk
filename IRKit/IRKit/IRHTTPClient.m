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

+ (void)post: (NSString*)path
  withParams: (NSDictionary*) params
targetNetwork: (enum IRHTTPClientNetwork)network
  completion: (void (^)(NSURLResponse *res, NSData* data, NSError *error))completion {
    LOG_CURRENT_METHOD;

    NSURL *url = [NSURL URLWithString:path relativeToURL:[self base]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.URL = url;
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.timeoutInterval = 60.;

    NSData *data = [self URLEncode:params];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
                               if (! completion) {
                                   return;
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   completion(res,data,error);
                               });
                           }];
}

+ (NSData *)URLEncode: (NSDictionary*)params {
    if ( ! params ) {
        return nil;
    }
    NSString *body = [[IRHelper mapObjects:params.allKeys
                               usingBlock:^id(id key, NSUInteger idx) {
                                   return [NSString stringWithFormat:@"%@=%@", key, params[key]];
                               }] componentsJoinedByString:@"&"];
    NSString *escaped = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (__bridge CFStringRef)body,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                              kCFStringEncodingUTF8);
    return [escaped dataUsingEncoding:NSUTF8StringEncoding];
}

@end
