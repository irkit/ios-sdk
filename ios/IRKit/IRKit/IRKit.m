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

    _peripherals = [[IRPeripherals alloc] init];
    _signals     = [[IRSignals alloc] init];
    _autoConnect = NO;
    _isScanning  = NO;
    _shouldScan  = NO;
    __weak IRKit *_self = self;
    _observer    = [[NSNotificationCenter defaultCenter]
                    addObserverForName:UIApplicationWillTerminateNotification
                                object:nil
                                queue:[NSOperationQueue mainQueue]
                           usingBlock:^(NSNotification *note) {
                      LOG( @"terminating" );
                      [_self save];
                  }];

    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}

- (void) startScan {
    LOG_CURRENT_METHOD;

    if (_manager.state == CBCentralManagerStatePoweredOn) {
        _isScanning = YES;

        // we want duplicates: peripheral updates receivedCount in adv packet when receiving IR data
        [_manager scanForPeripheralsWithServices:@[ IRKIT_SERVICE_UUID ]
                                         options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES
         }];
        // find anything
        // [_manager scanForPeripheralsWithServices:nil
        //                                  options:nil];
    }
    else {
        _shouldScan = YES; // scans when powered on
    }
}

- (void) stopScan {
    LOG_CURRENT_METHOD;
    _isScanning = NO;
    _shouldScan = NO;
    [_manager stopScan];
}

- (NSUInteger) numberOfPeripherals {
    LOG_CURRENT_METHOD;
    return _peripherals.countOfPeripherals;
}

- (NSUInteger) numberOfSignals {
    LOG_CURRENT_METHOD;
    return _signals.countOfSignals;
}

- (void) save {
    LOG_CURRENT_METHOD;
    [_peripherals save];
    [_signals save];
}

- (void) disconnectPeripheral: (IRPeripheral*)peripheral {
    LOG_CURRENT_METHOD;
    [_manager cancelPeripheralConnection: peripheral.peripheral];
}

- (void) retrieveKnownPeripherals {
    LOG_CURRENT_METHOD;

    NSArray *knownPeripherals = [_peripherals knownPeripheralUUIDs];
    if ([knownPeripherals count]) {
        LOG( @"retrieve: %@", knownPeripherals );
        [_manager retrievePeripherals: knownPeripherals];
    }
}

#pragma mark -
#pragma mark CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    LOG( @"peripheral: %@ advertisementData: %@ RSSI: %@", peripheral, advertisementData, RSSI );

    [_peripherals addPeripheralsObject:peripheral]; // retain
    IRPeripheral* p = [_peripherals IRPeripheralForPeripheral:peripheral];
    peripheral.delegate = p;

    NSData *data = advertisementData[CBAdvertisementDataManufacturerDataKey];
    uint8_t receivedCount;
    if (data) {
        [data getBytes:&receivedCount
                 range:(NSRange){0,1}];
        LOG( @"peripheral: %@ receivedCount: %d", peripheral, receivedCount );
    }

    // connect when:
    // * app not authorized = we need to connect to receive auth c12c's indication
    // * peripheral's received count has changed = peripheral should have received IR data, we're gonna read it
    if ( ! p.authorized ) {
        [_manager connectPeripheral:peripheral
                            options:@{
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES
         }];
    }
    else if ( (p.receivedCount != IRPERIPHERAL_RECEIVED_COUNT_UNKNOWN) &&
              (p.receivedCount != (uint16_t)receivedCount) ) {
        p.shouldReadIRData = YES;
        [_manager connectPeripheral:peripheral
                            options:@{
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES
         }];
    }
    p.receivedCount = receivedCount;
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
        peripheral.delegate = p;
        
        if (p.wantsToConnect) {
            [_manager connectPeripheral:peripheral
                                options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES }];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    LOG( @"peripheral: %@, RSSI: %@", peripheral, peripheral.RSSI );

    [[NSNotificationCenter defaultCenter]
                postNotificationName:IRKitDidConnectPeripheralNotification
                              object:nil];

    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    LOG( @"peripheral: %@ error: %@", peripheral, error);

    // TODO removeFromPeripherals??
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
