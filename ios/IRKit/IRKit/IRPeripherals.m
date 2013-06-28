//
//  IRPeripherals.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripherals.h"
#import "IRPersistentStore.h"
#import "IRHelper.h"

//#define LOG_DISABLED 1

@interface IRPeripherals ()

// just to retain a CBPeripheral without an UUID
@property (nonatomic) NSMutableSet* unknownPeripherals;

// CBPeripheral.UUID => IRPeripheral
@property (nonatomic) NSMutableDictionary* irperipheralForUUID;

@end

@implementation IRPeripherals

- (id)init {
    self = [super init];
    if (! self) { return nil; }
    
    _unknownPeripherals = [[NSMutableSet alloc] init];
    [self load];
        
    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);
    
    NSArray* keys = [_irperipheralForUUID keysSortedByValueUsingSelector:@selector(compareByFirstFoundDate:)];
    NSString* key = [keys objectAtIndex: key];
    return _irperipheralForUUID[key];
}

// returns NSArray of CFUUIDs
- (NSArray*) knownPeripheralUUIDs {
    LOG_CURRENT_METHOD;
    return [IRHelper mapObjects:[_irperipheralForUUID allKeys]
                     usingBlock:(id)^(id obj, NSUInteger idx) {
                         return (__bridge_transfer id)(CFUUIDCreateFromString(NULL, (CFStringRef)obj));
                     }];
}

- (IRPeripheral*)IRPeripheralForPeripheral: (CBPeripheral*)peripheral {
    LOG_CURRENT_METHOD;
    if ( ! peripheral.UUID ) {
        return nil;
    }
    NSString *uuidKey = [IRHelper stringFromCFUUID:peripheral.UUID];
    return _irperipheralForUUID[uuidKey];
}

- (IRPeripheral*)IRPeripheralForUUID: (NSString*)uuid {
    LOG_CURRENT_METHOD;
    if ( ! uuid ) {
        return nil;
    }
    return _irperipheralForUUID[uuid];
}

- (void) save {
    LOG_CURRENT_METHOD;
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_irperipheralForUUID];
    [IRPersistentStore storeObject:data
                            forKey:@"peripherals"];
    [IRPersistentStore synchronize];
}

#pragma mark -
#pragma Private methods

- (void) load {
    LOG_CURRENT_METHOD;
    
    NSData* data = [IRPersistentStore objectForKey: @"peripherals"];
    
    _irperipheralForUUID = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ( ! _irperipheralForUUID ) {
        _irperipheralForUUID = [[NSMutableDictionary alloc] init];
    }
    LOG( @"_irperipheralForUUID: %@", _irperipheralForUUID );
}

#pragma mark -
#pragma mark Key Value Coding - Mutable Unordered Accessors

- (NSArray*) peripherals {
    LOG_CURRENT_METHOD;
    
    return [_irperipheralForUUID allValues];
}

- (NSUInteger) countOfPeripherals {
    LOG_CURRENT_METHOD;
    
    return _irperipheralForUUID.count;
}

- (NSEnumerator *)enumeratorOfPeripherals {
    LOG_CURRENT_METHOD;
    
    return _irperipheralForUUID.objectEnumerator;
}

- (CBPeripheral*)memberOfPeripherals:(CBPeripheral *)peripheral {
    LOG_CURRENT_METHOD;
    
    if (!peripheral.UUID) {
        return nil;
    }
    NSString *uuid = [IRHelper stringFromCFUUID:peripheral.UUID];
    return _irperipheralForUUID[uuid];
}

// -add<Key>Object:
- (void)addPeripheralsObject:(CBPeripheral*) peripheral {
    LOG( @"peripheral: %@", peripheral );
    
    //    if ( ! peripheral.UUID || ! peripheral.name ) {
    if ( ! peripheral.UUID ) {
        // just to retain while 1st connect attempt
        [_unknownPeripherals addObject:peripheral];
        return;
    }
    // we got it's UUID, so don't need to retain peripheral in _unknownPeripherals anymore, we're gonna retain it in _irperipheralForUUID
    [_unknownPeripherals removeObject:peripheral];
    
    NSString *uuidKey = [IRHelper stringFromCFUUID:peripheral.UUID];
    IRPeripheral *p = _irperipheralForUUID[uuidKey];
    if (p) {
        // found known but disconnected peripheral
        p.peripheral = peripheral;
    }
    else {
        p                = [[IRPeripheral alloc] init];
        p.peripheral     = peripheral;
        p.customizedName = peripheral.name; // defaults to original name
        p.foundDate      = [NSDate date];
        p.isPaired       = @NO;
        _irperipheralForUUID[uuidKey] = p;
        [self save];
    }
}

- (void)removePeripheralsObject: (CBPeripheral*) peripheral {
    LOG( @"peripheral: %@", peripheral );
    
    if ( ! peripheral.UUID ) {
        [_unknownPeripherals removeObject:peripheral];
        return;
    }
    NSString *uuidKey = [IRHelper stringFromCFUUID:peripheral.UUID];
    [_irperipheralForUUID removeObjectForKey:uuidKey];
}

@end
