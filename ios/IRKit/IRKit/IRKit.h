//
//  IRKit.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "IRConst.h"
#import "IRReceiveViewController.h"
#import "IRNewPeripheralViewController.h"
#import "IRSignalSelectorViewController.h"
#import "IRPeripherals.h"
#import "IRSignals.h"
#import "IRSignal.h"
#import "IRSignalCell.h"
#import "IRChartView.h"

@interface IRKit : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

+ (IRKit*) sharedInstance;

- (void) startScan;
- (void) stopScan;
- (void) save;
- (void) writeIRPeripheral: (IRPeripheral*)peripheral
                     value: (NSData*)value
 forCharacteristicWithUUID: (CBUUID*)characteristicUUID
         ofServiceWithUUID: (CBUUID*)serviceUUID
                completion: (void (^)(NSError *error))block;
- (void) disconnectPeripheral: (IRPeripheral*)peripheral;

@property (nonatomic) BOOL autoConnect;
@property (nonatomic) BOOL isScanning;

@property (nonatomic, getter = numberOfPeripherals) NSUInteger numberOfPeripherals;
@property (nonatomic, getter = numberOfSignals) NSUInteger numberOfSignals;
@property (nonatomic, strong) IRPeripherals *peripherals;
@property (nonatomic, strong) IRSignals *signals;

@end
