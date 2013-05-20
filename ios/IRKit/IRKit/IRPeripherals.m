//
//  IRPeripherals.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripherals.h"

@interface IRPeripherals ()

@property (nonatomic, strong) NSMutableArray* peripherals; // array of IRPeripheral

@end

@implementation IRPeripherals

- (BOOL)containsObject:(id)object {
    LOG_CURRENT_METHOD;
    
    return [_peripherals containsObject:object];
}

- (void)addObject:(id)object {
    LOG( @"object: ", object );
    
    [_peripherals addObject:object];
}

- (NSUInteger) count {
    LOG_CURRENT_METHOD;
    return _peripherals.count;
}

@end
