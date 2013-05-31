//
//  IRPeripheral.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignal.h"

@implementation IRSignal

- (NSString*)name {
    LOG_CURRENT_METHOD;
    return @"name";
}

// array of number of 38kHz counter between edges
// 1st edge is ↓
- (NSArray*)data {
    LOG_CURRENT_METHOD;
    return @[ @100, @100, @100, @100, @100 ];
}

@end
