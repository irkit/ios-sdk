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
#import "IRNewPeripheralViewController.h"
#import "IRNewSignalViewController.h"
#import "IRPeripheralNameEditViewController.h"
#import "IRWebViewController.h"
#import "IRPeripherals.h"
#import "IRSignals.h"
#import "IRSignal.h"
#import "IRSignalCell.h"
#import "IRChartView.h"
#import "IRHelper.h"

@interface IRKit : NSObject<CBCentralManagerDelegate>

+ (IRKit*) sharedInstance;

- (void) startScan;
- (void) stopScan;
- (void) save;

// Stay connected in background,
// so that we can stay alive in background.
// We can also receive notifications.
// Only use this option when you want to send signals in background,
// and you don't have other way to awake when you want to.
// Use "Background App Refresh" or local/remote notifications when you can.
// Since BLE peripheral can connect with 1 central at a time,
// this might interrupt other apps to connect.
@property (nonatomic) BOOL retainConnectionInBackground;

@property (nonatomic, readonly) NSUInteger numberOfAuthorizedPeripherals;
@property (nonatomic, readonly) NSUInteger numberOfPeripherals;
@property (nonatomic) IRPeripherals *peripherals;

@end
