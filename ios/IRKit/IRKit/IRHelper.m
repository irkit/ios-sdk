//
//  IRHelper.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation IRHelper

+ (NSString*)stringFromCFUUID: (CFUUIDRef) uuid {
    if ( ! uuid ) {
        return nil;
    }
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

+ (CBCharacteristic*)findCharacteristicInSameServiceWithCharacteristic:(CBCharacteristic*)characteristic withCBUUID:(CBUUID*)uuid {
    LOG_CURRENT_METHOD;
    
    CBService *service = characteristic.service;
    if ( ! service ) {
        return nil;
    }
    for (CBCharacteristic *neighborCharacteristic in service.characteristics)
    {
        if ([neighborCharacteristic.UUID isEqual:uuid])
        {
            return neighborCharacteristic;
        }
    }
    return nil;
}

// array of short values
+ (NSString*) sha1:(NSArray*) array {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1_CTX ctx;
    CC_SHA1_Init(&ctx);
    for (size_t i = 0; i < array.count; i++) {
        uint16_t val = [array[i] shortValue];
        CC_SHA1_Update(&ctx, &val, sizeof(uint16_t));
    }
    CC_SHA1_Final(digest, &ctx);
    
    NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",digest[0], digest[1], digest[2], digest[3], digest[4], digest[5], digest[6], digest[7], digest[8], digest[9], digest[10], digest[11], digest[12], digest[13], digest[14], digest[15], digest[16], digest[17], digest[18], digest[19]];
    return s;
}

@end
