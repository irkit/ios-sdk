//
//  IRPeripheral.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//
// IRPeripheral stores additional info related to CBPeripheral

#import <Foundation/Foundation.h>

@interface IRPeripheral : NSObject<CBPeripheralDelegate>

// can be nil if peripheral is found but UUID isn't
@property (nonatomic) CFUUIDRef UUID;
@property (nonatomic, copy) NSString *customizedName;
@property (nonatomic, copy) NSDate   *foundDate;
@property (nonatomic) BOOL authorized;

@property (nonatomic) NSString *manufacturerName;
@property (nonatomic) NSString *modelName;
@property (nonatomic) NSString *hardwareRevision;
@property (nonatomic) NSString *firmwareRevision;
@property (nonatomic) NSString *softwareRevision;

- (BOOL) isReady;
- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral;

- (void) didDiscoverWithAdvertisementData:(NSDictionary*)data
                                     RSSI:(NSNumber*)rssi;
- (void) didRetrieve;
- (void) didConnect;
- (void) disconnect;
- (void) didDisconnect;

- (void) writeValueInBackground: (NSData*)value
      forCharacteristicWithUUID: (CBUUID*)characteristicUUID
              ofServiceWithUUID: (CBUUID*)serviceUUID
                     completion: (void (^)(NSError *error))block;
- (BOOL) writeValue: (NSData*)value
forCharacteristicWithUUID: (CBUUID*)characteristicUUID
  ofServiceWithUUID: (CBUUID*)serviceUUID;

- (NSString*) modelNameAndRevision;

- (void)setManager: (CBCentralManager*)manager;
- (void)setPeripheral: (CBPeripheral*)peripheral;

@end
