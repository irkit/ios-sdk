//
//  SRHelper.m
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/07/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "SRHelper.h"
#import "AFNetworking.h"

@implementation SRHelper

+ (void)uploadIcon:(UIImage *)image
        withIRData:(NSArray *)data
        withIRFreq:(int)freq
 completionHandler:(void (^)(NSHTTPURLResponse *response, NSDictionary *json, NSError *error)) completion {
    LOG_CURRENT_METHOD;

    NSURL *url = [NSURL URLWithString:@"http://localhost:8080"];

    NSMutableString *irstring = [NSMutableString stringWithCapacity:data.count];
    [data enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        uint16_t interval = [obj shortValue];
        if (idx == 0) {
            [irstring appendFormat:@"%x", interval];
        }
        else {
            [irstring appendFormat:@",%x", interval];
        }
    }];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                         path:@"/apps/one/icons/"
                                                                   parameters:@{@"irdata":irstring,
                                                                                @"irfreq":@38}
                                                    constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:UIImagePNGRepresentation(image)
                                    name:@"icon"
                                fileName:@"icon.png"
                                mimeType:@"image/png"];
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
