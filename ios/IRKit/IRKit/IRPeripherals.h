//
//  IRPeripherals.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRPeripherals : NSObject

- (void)addPeripheral:(CBPeripheral*) peripheral;
- (id)objectAtIndex:(NSUInteger)index;
- (NSArray*) knownPeripheralUUIDs;

@property (nonatomic, getter = count) NSUInteger count;

@end
