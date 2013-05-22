//
//  IRPeripherals.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripherals.h"

#define LOCAL_LOG_DISABLED

@interface IRPeripherals ()

@property (nonatomic, strong) NSMutableArray* peripherals; // array of IRPeripheral

@end

@implementation IRPeripherals

- (id)init {
    self = [super init];
    if (! self) { return nil; }
    
    _peripherals = [[NSMutableArray alloc] initWithArray:@[]];
    
    return self;
}

- (BOOL)containsObject:(id)object {
    LOG_CURRENT_METHOD;
    
    return [_peripherals containsObject:object];
}

- (void)addObject:(id)object {
    LOG( @"object: ", object );
    
    [_peripherals addObject:object];
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);
    
    return [_peripherals objectAtIndex:index];
}

- (NSUInteger) count {
    LOG_CURRENT_METHOD;
    
    return 1; // testing
    // return _peripherals.count;
}

@end
