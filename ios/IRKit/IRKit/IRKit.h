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
#import "IRPeripherals.h"
#import "IRSignals.h"

@interface IRKit : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

+ (IRKit*) sharedInstance;

- (void) startScan;
- (void) stopScan;

@property (nonatomic) BOOL autoConnect;
@property (nonatomic) BOOL isScanning;
@property (nonatomic) BOOL isAuthorized;

@property (nonatomic, getter = numberOfPeripherals) NSUInteger numberOfPeripherals;
@property (nonatomic, getter = numberOfSignals) NSUInteger numberOfSignals;
@property (nonatomic, strong) IRPeripherals *peripherals;
@property (nonatomic, strong) IRSignals *signals;

@end
