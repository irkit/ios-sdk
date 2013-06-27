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

@property (nonatomic, strong) NSMutableSet* signals; // set of IRSignal

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

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);
    
    NSArray* signals = [_signals sortedArrayUsingDescriptors:
                            @[ [NSSortDescriptor sortDescriptorWithKey: @"receivedDate"
                                                             ascending: NO] ]];
    return signals[index];
}

#pragma mark -
#pragma Private methods

- (void) load {
    LOG_CURRENT_METHOD;
    
    NSData* data = [IRPersistentStore objectForKey: @"signals"];
    
    _signals = (NSMutableSet*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ( ! _signals ) {
        _signals = [[NSMutableSet alloc] init];
    }
    LOG( @"_signals: %@", _signals );
}

#pragma mark -
#pragma mark Key Value Coding - Mutable Indexed Accessors

- (NSArray*) signals {
    return [_signals allObjects];
}

- (NSUInteger) countOfSignals {
    return _signals.count;
}

- (NSEnumerator*)enumeratorOfSignals {
    return _signals.objectEnumerator;
}

- (IRSignal*)memberOfSignals:(IRSignal *)object {
    
    // TODO don't allow same signal data to exist

    return [_signals member:object];
}

- (void)addSignalsObject:(IRSignal *)object {

    // TODO don't allow same signal data to exist
    
    [_signals addObject:object];
}

- (void)removeSignalsObject:(IRSignal *)object {
    [_signals removeObject:object];
}

@end
