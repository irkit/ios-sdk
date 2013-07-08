//
//  IRSignals.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignals.h"
#import "IRPersistentStore.h"
#import "IRConst.h"
#import "IRSignalCell.h"

@interface IRSignals ()

// IRSignal.uniqueID => IRSignal
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
    NSString* key = [keys objectAtIndex: index];
    return _signals[key];
}

- (void) save {
    LOG_CURRENT_METHOD;
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_signals];
    [IRPersistentStore storeObject:data
                            forKey:@"signals"];
    [IRPersistentStore synchronize];
}

#pragma mark - Private methods

- (void) load {
    LOG_CURRENT_METHOD;
    
    NSData* data = [IRPersistentStore objectForKey: @"signals"];
    
    NSMutableSet *set = (NSMutableSet*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ( set ) {
        _signals = set;
    }
    else {
        _signals = [[NSMutableDictionary alloc] init];
    }
    LOG( @"_signals: %@", _signals );
}

- (NSInteger) indexOfSignal: (IRSignal*) signal {
    LOG_CURRENT_METHOD;

    return [[_signals keysSortedByValueUsingSelector:@selector(compareByReceivedDate:)] indexOfObject:signal.uniqueID];
}

#pragma mark - Key Value Coding - Mutable Indexed Accessors

- (NSArray*) signals {
    return [_signals allValues];
}

- (NSUInteger) countOfSignals {
    return _signals.count;
}

- (NSEnumerator*)enumeratorOfSignals {
    // TODO sort using receivedDate
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
    
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            [_delegate controller:self
                  didChangeObject:object
                      atIndexPath:nil
                    forChangeType:IRAnimatingTypeInsert
                     newIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
        if ([_delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
            [_delegate controllerDidChangeContent:self];
        }
    }
}

- (void)removeSignalsObject:(IRSignal *)object {
    NSInteger row;
    if (_delegate) {
        row = [self indexOfSignal: object];
        if (row == NSNotFound) {
            LOG( @"something weird happened" );
        }
    }
    [_signals removeObjectForKey:object.uniqueID];
    
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            [_delegate controller:self
                  didChangeObject:object
                      atIndexPath:[NSIndexPath indexPathForRow:row
                                                     inSection:0]
                    forChangeType:IRAnimatingTypeDelete
                     newIndexPath:nil];
        }
        if ([_delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
            [_delegate controllerDidChangeContent:self];
        }
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG( @"indexPath.row: %d", indexPath.row);

    IRSignalCell *cell = (IRSignalCell*)[tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierSignal];
    if (cell == nil) {
        cell = [[IRSignalCell alloc] initWithReuseIdentifier:IRKitCellIdentifierSignal];
    }
    cell.signal = [self objectAtIndex: indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    return self.countOfSignals;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    return [IRSignalCell height];
}

@end
