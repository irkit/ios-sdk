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

// md5(signals) => IRSignal
@property (nonatomic, strong) NSMutableDictionary* signals;

@end

@implementation IRSignals

- (id)init {
    self = [super init];
    if (! self) { return nil; }
    
    [self load];
    
    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);
    
    NSArray* keys = [_signals keysSortedByValueUsingSelector:@selector(compareByReceivedDate:)];
    NSString* key = [keys objectAtIndex: key];
    return _signals[key];
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
    
    _signals = (NSMutableSet*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ( ! _signals ) {
        _signals = [[NSMutableDictionary alloc] init];
    }
    LOG( @"_signals: %@", _signals );
}

#pragma mark -
#pragma mark Key Value Coding - Mutable Indexed Accessors

- (NSArray*) signals {
    return [_signals allValues];
}

- (NSUInteger) countOfSignals {
    return _signals.count;
}

- (NSEnumerator*)enumeratorOfSignals {
    return _signals.objectEnumerator;
}

- (IRSignal*)memberOfSignals:(IRSignal *)object {
    LOG_CURRENT_METHOD;
    
    return _signals[object.uniqueID];
}

- (void)addSignalsObject:(IRSignal *)object {

    if ( [self memberOfSignals:object] ) {
        return;
    }
    
    _signals[object.uniqueID] = object;
}

- (void)removeSignalsObject:(IRSignal *)object {
    [_signals removeObjectForKey:object.uniqueID];
}

@end
