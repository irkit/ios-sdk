//
//  IRSignals.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignals.h"
#import "IRPersistentStore.h"

@interface IRSignals ()

@property (nonatomic, strong) NSMutableArray* signals; // array of IRSignal

@end

@implementation IRSignals

- (id)init {
    self = [super init];
    if (! self) { return nil; }
    
    [self load];
    
    return self;
}

- (void) save {
    LOG_CURRENT_METHOD;
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_signals];
    [IRPersistentStore storeObject:data
                            forKey:@"signals"];
    [IRPersistentStore synchronize];
}

#pragma mark -
#pragma Private methods

- (void) load {
    LOG_CURRENT_METHOD;
    
    NSData* data = [IRPersistentStore objectForKey: @"signals"];
    
    _signals = (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ( ! _signals ) {
        _signals = [[NSMutableArray alloc] init];
    }
    LOG( @"_signals: %@", _signals );
}

#pragma mark -
#pragma mark Key Value Coding - Mutable Indexed Accessors

- (NSArray*) signals {
    return _signals;
}


- (NSUInteger) countOfSignals {
    return _signals.count;
}

- (id)objectInSignalsAtIndex:(NSUInteger)index {
    return [_signals objectAtIndex:index];
}

- (void) insertObject:(IRSignal *)object inSignalsAtIndex:(NSUInteger)index {
    [_signals insertObject:object atIndex:index];
}

- (void) removeObjectFromSignalsAtIndex:(NSUInteger)index {
    [_signals removeObjectAtIndex:index];
}

- (void) replaceObjectInSignalsAtIndex:(NSUInteger)index withObject:(id)object {
    [_signals replaceObjectAtIndex:index withObject:object];
}

@end
