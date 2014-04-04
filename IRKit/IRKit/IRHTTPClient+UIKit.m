//
//  IRHTTPClient+UIKit.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/04/02.
//
//

#import "IRHTTPClient+UIKit.h"
#import "Log.h"

@implementation IRHTTPClient (UIKit)

+ (void)    loadImage:(NSString *)url
    completionHandler:(void (^)(NSHTTPURLResponse *response, UIImage *image, NSError *error))handler {
    LOG_CURRENT_METHOD;

    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: url]
                                             cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 60.];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
        UIImage *ret;
        if (!error) {
            ret = [UIImage imageWithData: data];
        }
        if (!handler) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
                handler((NSHTTPURLResponse *)res, ret, error);
            });
    }];
}

@end
