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

// NSMutableSet of CBPeripherals
@property (nonatomic, strong) NSMutableSet* peripherals;

// CBPeripheral.UUID => IRPeripheral
@property (nonatomic, strong) NSMutableDictionary* irperipheralForUUID;

@end

@implementation IRPeripherals

- (id)init {
    self = [super init];
    if (! self) { return nil; }
    
    [self load];
    
    _peripherals = [[NSMutableSet alloc] init];
    
    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);
    
    NSArray* keys = [_irperipheralForUUID keysSortedByValueUsingSelector:@selector(compareByFirstFoundDate:)];
    NSString* key = [keys objectAtIndex: key];
    return _irperipheralForUUID[key];
}

- (NSArray*) knownPeripheralUUIDs {
    LOG_CURRENT_METHOD;
    return [_irperipheralForUUID allKeys];
}

- (IRPeripheral*)IRPeripheralForPeripheral: (CBPeripheral*)peripheral {
    LOG_CURRENT_METHOD;
    if ( ! peripheral.UUID ) {
        return nil;
    }
    NSString *uuidKey = [IRHelper stringFromCFUUID:peripheral.UUID];
    return _irperipheralForUUID[uuidKey];
}


#pragma mark -
#pragma mark Key Value Coding - Mutable Unordered Accessors

- (NSSet*) peripherals {
    LOG_CURRENT_METHOD;
    
    return _peripherals;
}

- (NSUInteger) countOfPeripherals {
    LOG_CURRENT_METHOD;
    
    return _peripherals.count;
}

- (NSEnumerator *)enumeratorOfPeripherals {
    LOG_CURRENT_METHOD;
    
    return _peripherals.objectEnumerator;
}

- (CBPeripheral*)memberOfPeripherals:(CBPeripheral *)object {
    LOG_CURRENT_METHOD;
    
    return [_peripherals member:object];
}

// -add<Key>Object:
- (void)addPeripheralsObject:(CBPeripheral*) peripheral {
    LOG( @"peripheral: %@", peripheral );
    
    if ( ! peripheral.UUID || ! peripheral.name ) {
        return;
    }
    
    NSString *uuidKey = [IRHelper stringFromCFUUID:peripheral.UUID];
    IRPeripheral *p = _irperipheralForUUID[uuidKey];
    if (p) {
        // found known but disconnected peripheral
        p.peripheral = peripheral;
    }
    else {
        p                = [[IRPeripheral alloc] init];
        p.peripheral     = nil;
        p.customizedName = peripheral.name; // defaults to original name
        p.foundDate      = [NSDate date];
        p.isPaired       = @NO;
        [_irperipheralForUUID setObject:p
                                 forKey:uuidKey];
        [self save];
    }
    [_peripherals addObject:peripheral];
}

- (void)removePeripheralsObject: (CBPeripheral*) peripheral {
    LOG( @"peripheral: %@", peripheral );
    
    [_peripherals removeObject:peripheral];
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

@end
