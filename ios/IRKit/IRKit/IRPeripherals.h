//
//  IRPeripherals.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRPeripherals : NSObject

- (NSInteger)addPeripheral:(CBPeripheral*) peripheral;
- (void)removePeripheral: (CBPeripheral*) peripheral;

- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger) count;

- (NSArray*) knownPeripheralUUIDs;

@property (nonatomic, getter = count) NSUInteger count;

@end
