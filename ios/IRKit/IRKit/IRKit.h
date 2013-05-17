//
//  IRKit.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
//#import "IRReceiveViewController.h"

@interface IRKit : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

+ (IRKit*) sharedInstance;
- (void) startScan;
- (void) stopScan;
@property BOOL autoConnect;

@end
