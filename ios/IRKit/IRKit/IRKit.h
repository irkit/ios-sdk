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

@interface IRKit : NSObject<CBCentralManagerDelegate>

+ (IRKit*) sharedInstance;

- (void) startScan;
- (void) stopScan;
- (void) save;

@property (nonatomic) BOOL retainConnectionInBackground;

@property (nonatomic, readonly) NSUInteger numberOfAuthorizedPeripherals;
@property (nonatomic, readonly) NSUInteger numberOfPeripherals;
@property (nonatomic) IRPeripherals *peripherals;

@end
