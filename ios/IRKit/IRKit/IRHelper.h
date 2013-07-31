//
//  IRHelper.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IRHelper : NSObject

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block;
+ (NSString*) sha1:(NSArray*) array;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageInResourceNamed:(NSString*)name;

+ (NSString*)stringFromCFUUID: (CFUUIDRef) uuid;
+ (BOOL)CBUUID: (CBUUID*)uuid1 isEqualToCBUUID: (CBUUID*)uuid2;

+ (CBService*)findServiceInPeripheral:(CBPeripheral*)peripheral withUUID:(CBUUID*)serviceUUID;
+ (CBCharacteristic*)findCharacteristicInPeripheral:(CBPeripheral*)peripheral withCBUUID:(CBUUID*)uuid;
+ (CBCharacteristic*)findCharacteristicInPeripheral:(CBPeripheral*)peripheral
                                         withCBUUID:(CBUUID*)characteristicUUID
                                inServiceWithCBUUID:(CBUUID*)serviceUUID;
+ (CBCharacteristic*)findCharacteristicInSameServiceWithCharacteristic:(CBCharacteristic*)characteristic
                                                            withCBUUID:(CBUUID*)uuid;
+ (void)loadImage:(NSString*)url
completionHandler:(void (^)(NSHTTPURLResponse *response, UIImage *image, NSError *error)) handler;

@end
