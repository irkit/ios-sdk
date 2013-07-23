//
//  SRHelper.h
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/07/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRHelper : NSObject

+ (void)uploadIcon:(UIImage *)image
        withIRData:(NSArray *)data
        withIRFreq:(int)freq
 completionHandler:(void (^)(NSHTTPURLResponse *response, NSDictionary *json, NSError *error)) handler;

@end
