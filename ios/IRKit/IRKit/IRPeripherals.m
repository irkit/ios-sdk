//
//  IRPeripherals.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripherals.h"
#import "IRPeripheral.h"
#import "IRPersistentStore.h"
#import "IRHelper.h"

//#define LOG_DISABLED 1

@interface IRPeripherals ()

// array of CBPeripheral
@property (nonatomic, strong) NSMutableArray* peripherals;

// CBPeripheral.UUID => IRPeripheral
@property (nonatomic, strong) NSMutableDictionary* irperipheralForUUID;

@end

@implementation IRPeripherals

- (id)init {
    self = [super init];
    if (! self) { return nil; }
    
    [self load];
    
    _peripherals = [[NSMutableArray alloc] init];
    
    return self;
}

- (NSInteger)addPeripheral:(CBPeripheral*) peripheral {
    LOG( @"peripheral: %@", peripheral );
    
    [_peripherals addObject:peripheral];
    
    if ( ! peripheral.UUID || ! peripheral.name ) {
        return -1;
    }
    
    NSString *uuidKey = [IRHelper stringFromCFUUID:peripheral.UUID];
    IRPeripheral *p = [_irperipheralForUUID objectForKey: uuidKey];
    if (p) {
        // found known but disconnected peripheral
        p.peripheral = peripheral;
        return -1;
    }

    p                = [[IRPeripheral alloc] init];
    p.peripheral     = nil;
    p.customizedName = peripheral.name; // defaults to original name
    p.foundDate      = [NSDate date];
    p.isPaired       = @NO;
    [_irperipheralForUUID setObject:p
                             forKey:uuidKey];
    [self save];
    
    // new peripheral is inserted in index:0
    // because we provide our peripherals with foundDate DESC order
    return 0;
}

- (void)removePeripheral: (CBPeripheral*) peripheral {
    LOG( @"peripheral: %@", peripheral );
    
    [_peripherals removeObject:peripheral];
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);
    
    NSArray* keys = [_irperipheralForUUID keysSortedByValueUsingSelector:@selector(compareByFirstFoundDate:)];
    NSString* key = [keys objectAtIndex: key];
    return [_irperipheralForUUID objectForKey: key];
}

- (NSUInteger) count {
    LOG_CURRENT_METHOD;
    
    return _irperipheralForUUID.count;
}

- (NSArray*) knownPeripheralUUIDs {
    LOG_CURRENT_METHOD;
    return [_irperipheralForUUID allKeys];
}

#pragma mark -
#pragma Private methods

- (void) save {
    LOG_CURRENT_METHOD;
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_irperipheralForUUID];
    [IRPersistentStore storeObject:data
                            forKey:@"peripherals"];
    [IRPersistentStore synchronize];
}

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
