//
//  IRKit.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRKit.h"
#import "IRFunc.h" // private
#import "IRPeripheral.h"
#import "IRHelper.h"

@interface IRKit ()

@property (nonatomic) CBCentralManager* manager;
@property (nonatomic) BOOL shouldScan;
@property (nonatomic) id observer;

@end

@implementation IRKit

+ (id) sharedInstance {
    static IRKit* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[IRKit alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (! self) { return nil; }

    _manager = [[CBCentralManager alloc] initWithDelegate:self
                                                    queue:nil];

    _peripherals = [[IRPeripherals alloc] initWithManager:_manager];
    _shouldScan  = NO;
    _observer    = [[NSNotificationCenter defaultCenter]
                    addObserverForName:UIApplicationWillTerminateNotification
                                object:nil
                                queue:[NSOperationQueue mainQueue]
                           usingBlock:^(NSNotification *note) {
                      LOG( @"terminating" );
                      [[IRKit sharedInstance] save];
                  }];
    _retainConnectionInBackground = NO;

    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}

- (void) save {
    LOG_CURRENT_METHOD;
    [_peripherals save];
}

- (BOOL) canHandleOpenURL: (NSURL*)url {
    LOG( @"url: %@", url );
    return YES;
}

- (void) handleOpenURL: (NSURL*)url {
    LOG( @"url: %@", url );

    
}

- (NSUInteger) numberOfAuthorizedPeripherals {
    LOG_CURRENT_METHOD;
    return _peripherals.countOfAuthorizedPeripherals;
}

- (NSUInteger) numberOfPeripherals {
    LOG_CURRENT_METHOD;
    return _peripherals.countOfPeripherals;
}

- (void) startScan {
    LOG_CURRENT_METHOD;
    
    if (_manager.state == CBCentralManagerStatePoweredOn) {
        // we want duplicates:
        // peripheral updates receivedCount in adv packet when receiving IR data
        [_manager scanForPeripheralsWithServices:@[ IRKIT_SERVICE_UUID ]
                                         options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES
         }];
    }
    else {
        _shouldScan = YES; // starts scanning when powered on
    }
}

- (void) stopScan {
    LOG_CURRENT_METHOD;
    _shouldScan = NO;
    [_manager stopScan];
}

#pragma mark - Private

- (void) retrieveKnownPeripherals {
    LOG_CURRENT_METHOD;
    
    NSArray *knownPeripherals = [_peripherals knownPeripheralUUIDs];
    if ([knownPeripherals count]) {
        LOG( @"retrieve: %@", knownPeripherals );
        [_manager retrievePeripherals: knownPeripherals];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    // LOG( @"peripheral: %@ advertisementData: %@ RSSI: %@", peripheral, advertisementData, RSSI );

    [_peripherals addPeripheralsObject:peripheral]; // retain
    IRPeripheral* p = [_peripherals IRPeripheralForPeripheral:peripheral];
    [p didDiscoverWithAdvertisementData: advertisementData
                                   RSSI: RSSI];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    LOG(@"peripheral: %@", peripheral);

}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 */
- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals {
    LOG( @"peripherals: %@", peripherals);

    for (CBPeripheral *peripheral in peripherals) {
        [_peripherals addPeripheralsObject:peripheral]; // retain
        IRPeripheral* p = [_peripherals IRPeripheralForPeripheral:peripheral];
        [p didRetrieve];
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    LOG( @"peripheral: %@, RSSI: %@", peripheral, peripheral.RSSI );

    IRPeripheral *p = [_peripherals IRPeripheralForPeripheral:peripheral];
    [p didConnect];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    LOG( @"peripheral: %@ error: %@", peripheral, error);

    IRPeripheral *p = [_peripherals IRPeripheralForPeripheral:peripheral];
    [p didDisconnect];

    // hack
    // see http://stackoverflow.com/questions/9896562/what-exactly-can-corebluetooth-applications-do-whilst-in-the-background/17484051#17484051
    [self stopScan];
    [self startScan];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    LOG( @"state: %@", NSStringFromCBCentralManagerState([central state]));

    if (_shouldScan && (central.state == CBCentralManagerStatePoweredOn)) {
        _shouldScan = NO;

        [self retrieveKnownPeripherals];
        [self startScan];
    }
}

@end
