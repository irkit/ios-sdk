//
//  IRSignals.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignals.h"

@interface IRSignals ()

@property (nonatomic, strong) NSMutableArray* signals; // array of IRSignal

@end

@implementation IRSignals

- (id)init {
    self = [super init];
    if (! self) { return nil; }
    
    _signals = [[NSMutableArray alloc] initWithCapacity:0];
    
    return self;
}

- (BOOL)containsObject:(id)object {
    LOG_CURRENT_METHOD;
    
    return [_signals containsObject:object];
}

- (void)addObject:(id)object {
    LOG( @"object: ", object );
    
    [_signals addObject:object];
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);
    
    return [_signals objectAtIndex:index];
}

- (NSUInteger) count {
    LOG_CURRENT_METHOD;
    
    return _signals.count;
}

@end
