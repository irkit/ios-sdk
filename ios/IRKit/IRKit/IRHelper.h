//
//  IRHelper.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRHelper : NSObject

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block;
+ (NSString*) sha1:(NSArray*) array;

+ (NSString*)stringFromCFUUID: (CFUUIDRef) uuid;
+ (BOOL)CBUUID: (CBUUID*)uuid1 isEqualToCBUUID: (CBUUID*)uuid2;

+ (CBCharacteristic*)findCharacteristicInPeripheral:(CBPeripheral*)peripheral withCBUUID:(CBUUID*)uuid;
+ (CBCharacteristic*)findCharacteristicInSameServiceWithCharacteristic:(CBCharacteristic*)characteristic withCBUUID:(CBUUID*)uuid;

@end
