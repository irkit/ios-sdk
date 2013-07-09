//
//  IRPeripheral.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//
// IRPeripheral stores additional info related to CBPeripheral

#import <Foundation/Foundation.h>

// receivedCount is uint8_t and can't be 0xFFFF
#define IRPERIPHERAL_RECEIVED_COUNT_UNKNOWN 0xFFFF

@interface IRPeripheral : NSObject<CBPeripheralDelegate>

@property (nonatomic, copy) NSString *customizedName;
@property (nonatomic, copy) NSDate   *foundDate;
@property (nonatomic) CBPeripheral *peripheral;
@property (nonatomic) uint16_t receivedCount;
@property (nonatomic) BOOL authorized;
@property (nonatomic) BOOL shouldReadIRData;
@property (nonatomic) BOOL wantsToConnect;

- (BOOL) isReady;
- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral;
- (void) writeData: (NSData*)value
forCharacteristicWithUUID: (CBUUID*)characteristicUUID
 ofServiceWithUUID: (CBUUID*)serviceUUID
        completion: (void (^)(NSError *error))block;
- (void) didDisconnect;

@end
