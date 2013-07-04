//
//  IRHelper.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRHelper : NSObject

+ (NSString*)stringFromCFUUID: (CFUUIDRef) uuid;
+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block;
+ (CBCharacteristic*)findCharacteristicInPeripheral:(CBPeripheral*)peripheral withCBUUID:(CBUUID*)uuid;
+ (CBCharacteristic*)findCharacteristicInSameServiceWithCharacteristic:(CBCharacteristic*)characteristic withCBUUID:(CBUUID*)uuid;
+ (NSString*) sha1:(NSArray*) array;

@end
