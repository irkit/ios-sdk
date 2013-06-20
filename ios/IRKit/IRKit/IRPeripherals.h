//
//  IRPeripherals.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRPeripheral.h"

@interface IRPeripherals : NSObject

- (id)objectAtIndex:(NSUInteger)index;
- (NSArray*) knownPeripheralUUIDs;
- (IRPeripheral*)IRPeripheralForPeripheral: (CBPeripheral*)peripheral;

#pragma mark -
#pragma mark Key Value Coding - Mutable Unordered Accessors

- (NSSet*) peripherals;
- (NSUInteger) countOfPeripherals;
- (NSEnumerator *)enumeratorOfPeripherals;
- (CBPeripheral*)memberOfPeripherals:(CBPeripheral *)object;
- (void)addPeripheralsObject:(CBPeripheral*) peripheral;
- (void)removePeripheralsObject: (CBPeripheral*) peripheral;
- (void) save;

@end
