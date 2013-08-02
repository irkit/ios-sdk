//
//  ONHelper.h
//  One
//
//  Created by Masakazu Ohtsuka on 2013/07/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONHelper : NSObject

+ (void)createIRSignalsIcon:(UIImage *)image
          completionHandler:(void (^)(NSHTTPURLResponse *response, NSDictionary *json, NSError *error)) handler;

@end
