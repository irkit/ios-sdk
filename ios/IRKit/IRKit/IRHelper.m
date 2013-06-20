//
//  IRHelper.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRHelper.h"

@implementation IRHelper

+ (NSString*)stringFromCFUUID: (CFUUIDRef) uuid {
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    return (__bridge_transfer NSString *)string;
}

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

@end
