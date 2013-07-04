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
@property (nonatomic, copy) void (^writeResponseBlock)(NSError *error);
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

- (void) writeIRPeripheral: (IRPeripheral*)peripheral
                     value: (NSData*)value
 forCharacteristicWithUUID: (CBUUID*)characteristicUUID
         ofServiceWithUUID: (CBUUID*)serviceUUID
                completion: (void (^)(NSError *error))block {
    LOG( @"peripheral: %@ service: %@ c12c: %@ value: %@", peripheral, serviceUUID, characteristicUUID, value );
    CBPeripheral *p = peripheral.peripheral;
    if ( _writeResponseBlock ) {
        // TODO already writing??
    }
    if ( ! p ) {
        // TODO no peripheral?
    }
    if ( ! p.isConnected ) {
        // TODO not connected

    }
    for (CBService *service in p.services) {
        if ( [service.UUID isEqual:serviceUUID]) {
            for (CBCharacteristic *c12c in service.characteristics) {
                if ([c12c.UUID isEqual:characteristicUUID]) {
                    _writeResponseBlock = block;
                    [p writeValue:value
                forCharacteristic:c12c
                             type:CBCharacteristicWriteWithResponse];
                    return;
                }
            }
        }
    }
    NSError *error;
    // TODO no c12c found
    block( error );
}

- (void) disconnectPeripheral: (IRPeripheral*)peripheral {
    LOG_CURRENT_METHOD;
    [_manager cancelPeripheralConnection: peripheral.peripheral];
}

#pragma mark -
#pragma mark CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    LOG( @"peripheral: %@ advertisementData: %@ RSSI: %@", peripheral, advertisementData, RSSI );

    [_peripherals addPeripheralsObject:peripheral]; // retain
    peripheral.delegate = self;

    IRPeripheral* p = [_peripherals IRPeripheralForPeripheral:peripheral];
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
    else if (p.receivedCount != receivedCount) {
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

- (void)centralManager:(CBCentralManager *)central
didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    LOG(@"peripherals: %@", peripherals);

}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 */
- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals {
    LOG( @"peripherals: %@", peripherals);

    for (CBPeripheral *peripheral in peripherals) {
        [_peripherals addPeripheralsObject:peripheral]; // retain
        peripheral.delegate = self;

//        [_manager connectPeripheral:peripheral
//                            options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES }];
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

        NSArray *knownPeripherals = [_peripherals knownPeripheralUUIDs];
        if ([knownPeripherals count]) {
            LOG( @"retrieve: %@", knownPeripherals );
            [_manager retrievePeripherals: knownPeripherals];
        }

        [self startScan];
    }
}

#pragma mark -
#pragma mark CBPeripheralDelegate

/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    LOG( @"peripheral: %@ error: %@", peripheral, error);

    for (CBService *service in peripheral.services)
    {
        LOG(@"service: %@ UUID: %@", service, service.UUID);

        // discover characterstics for all services (just interested now)
        [peripheral discoverCharacteristics:IRKIT_CHARACTERISTICS
                                 forService:service];

//        // Device Information Service
//        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
//        {
//            [peripheral discoverCharacteristics:nil forService:service];
//        }
//
//        // GAP (Generic Access Profile) for Device Name
//        if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
//        {
//            [peripheral discoverCharacteristics:nil forService:service];
//        }
//
//        // GATT (Generic Attribute Profile)
//        if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAttributeProfileString]] )
//        {
//            [peripheral discoverCharacteristics:nil forService:service];
//        }
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void) peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
              error:(NSError *)error
{
    LOG( @"peripheral: %@ service: %@ error: %@", peripheral, service, error);
    IRPeripheral *p = [_peripherals IRPeripheralForPeripheral:peripheral];

    for (CBCharacteristic *characteristic in service.characteristics)
    {
        LOG( @"characteristic: %@, UUID: %@, value: %@, descriptors: %@, properties: %@, isNotifying: %d, isBroadcasted: %d",
            characteristic, characteristic.UUID, characteristic.value, characteristic.descriptors, NSStringFromCBCharacteristicProperty(characteristic.properties), characteristic.isNotifying, characteristic.isBroadcasted );
    }

    if ([service.UUID isEqual:IRKIT_SERVICE_UUID]) {
        // make sure we're not eternally connected
        BOOL shouldStayConnected = NO;
        
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_AUTHORIZATION_UUID]) {
                if ( ! p.authorized ) {
                    LOG( @"are we authorized?" );
                    [peripheral setNotifyValue:YES
                             forCharacteristic:characteristic];
                    [peripheral readValueForCharacteristic:characteristic];
                    shouldStayConnected = YES;
                }
            }
            else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_IR_DATA_UUID]) {
                if ( p.authorized && p.shouldReadIRData ) {
                    LOG( @"read IR data" );
                    p.shouldReadIRData = NO;
                    [peripheral readValueForCharacteristic:characteristic];
                    shouldStayConnected = YES;
                }
            }
        }

        if ( ! shouldStayConnected ) {
            [p restartDisconnectTimer];
        }
    }
    
//    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]])
//    {
//        for (CBCharacteristic *characteristic in service.characteristics)
//        {
//            /* Set notification on heart rate measurement */
//            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
//            {
//                [peripheral setNotifyValue:YES
//                          forCharacteristic:characteristic];
//                LOG(@"Found a Heart Rate Measurement Characteristic");
//            }
//            /* Read body sensor location */
//            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
//            {
//                [peripheral readValueForCharacteristic:characteristic];
//                LOG(@"Found a Body Sensor Location Characteristic");
//            }
//
//            /* Write heart rate control point */
//            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])
//            {
//                uint8_t val = 1;
//                NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
//                [peripheral writeValue:valData forCharacteristic:characteristic
//                                   type:CBCharacteristicWriteWithResponse];
//            }
//        }
//    }

//    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
//    {
//        for (CBCharacteristic *characteristic in service.characteristics)
//        {
//            /* Read device name */
//            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
//            {
//                [peripheral readValueForCharacteristic:characteristic];
//                LOG(@"Found a Device Name Characteristic, RSSI: %@", peripheral.RSSI);
//            }
//        }
//    }
//
//    // org.bluetooth.service.device_information
//    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
//    {
//        for (CBCharacteristic *characteristic in service.characteristics)
//        {
//            // Read manufacturer name
//            // 2a29: org.bluetooth.characteristic.manufacturer_name_string
//            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
//            {
//                [peripheral readValueForCharacteristic:characteristic];
//                LOG(@"Found a Device Manufacturer Name Characteristic");
//            }
//        }
//    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
              error:(NSError *)error
{
    LOG( @"peripheral: %@ charactristic: %@ UUID: %@ value: %@ error: %@", aPeripheral, characteristic, characteristic.UUID, characteristic.value, error);

    // disconnect when authorized
    // we connect only when we need to
    IRPeripheral *p = [_peripherals IRPeripheralForPeripheral:aPeripheral];

    if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_AUTHORIZATION_UUID]) {
        NSData *value = characteristic.value;
        unsigned char authorized = 0;
        [value getBytes:&authorized length:1];
        LOG( @"authorized: %d", authorized );

        if (authorized) {
            p.authorized = YES;
            [_peripherals save];

            [[NSNotificationCenter defaultCenter]
                postNotificationName:IRKitPeripheralAuthorizedNotification
                              object:nil];
            [p restartDisconnectTimer];
        }
        else {
            // retain connection while waiting for user to press auth switch
        }
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_IR_DATA_UUID]) {
        NSData *value = characteristic.value;
        LOG( @"value.length: %d", value.length );
        IRSignal *signal = [[IRSignal alloc] initWithData: value];
        signal.peripheral = p;
        if (! [_signals memberOfSignals:signal]) {
            [_signals addSignalsObject:signal];
            [_signals save];
        }
        [p restartDisconnectTimer];
    }

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) {
        NSString * deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Device Name = %@", deviceName);
    }
    // 2a29: org.bluetooth.characteristic.manufacturer_name_string
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) {
        NSString* manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Manufacturer Name = %@", manufacturer);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    LOG( @"peripheral: %@ charactristic: %@ UUID: %@ error: %@", peripheral, characteristic, characteristic.UUID, error);

    if (_writeResponseBlock) {
        _writeResponseBlock(error);
        _writeResponseBlock = nil;
    }
    IRPeripheral *p = [_peripherals IRPeripheralForPeripheral:peripheral];
    [p restartDisconnectTimer];
}

@end
