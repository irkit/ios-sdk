//
//  SRHelper.m
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/07/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "SRHelper.h"
#import "AFNetworking.h"
#import "SRSignals.h"

@implementation SRHelper

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (void)createIRSignalsIcon:(UIImage *)image
          completionHandler:(void (^)(NSHTTPURLResponse *, NSDictionary *, NSError *))completion {
    LOG_CURRENT_METHOD;

    NSURL *url = [NSURL URLWithString:@"http://localhost:8080"];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                         path:@"/apps/one/icons/"
                                                                   parameters:nil
                                                    constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                        [formData appendPartWithFileData:UIImagePNGRepresentation(image)
                                                                                    name:@"icon"
                                                                                fileName:@"icon.png"
                                                                                mimeType:@"image/png"];
                                                        NSString *json = [SRSignals sharedInstance].signals.JSONRepresentation;
                                                        NSData *data = [NSData dataWithBytes:[json UTF8String]
                                                                                      length:[json lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
                                                        [formData appendPartWithFileData:data
                                                                                    name:@"irsignals"
                                                                                fileName:@"irsignals.json"
                                                                                mimeType:@"application/json"];
    }];

    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *req, NSHTTPURLResponse *res, id JSON) {
                                                        LOG(@"success");
                                                        completion(res, JSON, nil);
                                                    } failure:^(NSURLRequest *req, NSHTTPURLResponse *res, NSError *err, id JSON) {
                                                        LOG(@"failure");
                                                        completion(res, JSON, err);
                                                    }];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        LOG(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [httpClient enqueueHTTPRequestOperation:operation];
}

@end
