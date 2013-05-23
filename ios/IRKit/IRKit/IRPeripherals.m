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

@property (nonatomic, strong) NSMutableArray* peripherals; // array of CBPeripheral

// CBPeripheral.UUID => name :NSString
@property (nonatomic, strong) NSMutableDictionary* customNameForPeripheralUUID;

@end

@implementation IRPeripherals

- (id)init {
    self = [super init];
    if (! self) { return nil; }
    
    _customNameForPeripheralUUID = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)[IRPersistentStore objectForKey: @"peripherals"]];
    LOG( @"_customNameForPeripheralUUID: %@", _customNameForPeripheralUUID );
    
    _peripherals = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)addPeripheral:(CBPeripheral*) peripheral {
    LOG( @"peripheral: %@", peripheral );
    
    [_peripherals addObject:peripheral];
    
    if (peripheral.UUID &&
        peripheral.name &&
        ! [_customNameForPeripheralUUID objectForKey: peripheral.UUID])
    {
        [_customNameForPeripheralUUID setObject:peripheral.name
                                         forKey:[IRHelper stringFromCFUUID:peripheral.UUID]];
        [self save];
    }
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);
    
    return [_peripherals objectAtIndex:index];
}

- (NSUInteger) count {
    LOG_CURRENT_METHOD;
    
    return _peripherals.count;
}

- (NSArray*) knownPeripheralUUIDs {
    LOG_CURRENT_METHOD;
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity: _peripherals.count];
    [_peripherals enumerateObjectsUsingBlock:
     ^(id currentObject, NSUInteger idx, BOOL *stop)
     {
         [ret addObject: (id)( ((IRPeripheral*) currentObject).UUID ) ];
     }
     ];
    return ret;
}

#pragma mark -
#pragma Private methods

- (void) save {
    LOG_CURRENT_METHOD;
    
    [IRPersistentStore storeObject:_customNameForPeripheralUUID
                            forKey:@"peripherals"];
    [IRPersistentStore synchronize];
}

@end
