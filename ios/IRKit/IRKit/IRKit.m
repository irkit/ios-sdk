//
//  IRKit.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRKit.h"
#import "IRFunc.h" // private

@interface IRKit ()

@property (nonatomic, strong) CBCentralManager* manager;

@end

@implementation IRKit

@synthesize autoConnect;

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
    NSArray *knownPeripherals = [_peripherals knownPeripheralUUIDs];
    if ([knownPeripherals count]) {
        LOG( @"retrieve: %@", knownPeripherals );
        [_manager retrievePeripherals: knownPeripherals];
    }
    
    _signals = [[IRSignals alloc] init];

    return self;
}

- (void) startScan {
    LOG_CURRENT_METHOD;
    
    [_manager scanForPeripheralsWithServices:@[ IRKIT_SERVICE_UUID ]
                                     options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
    // find anything
//    [_manager scanForPeripheralsWithServices:nil
//                                     options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
}

- (void) stopScan {
    LOG_CURRENT_METHOD;
    [_manager stopScan];
}

- (NSUInteger) numberOfPeripherals {
    LOG_CURRENT_METHOD;
    return [_peripherals count];
}

- (NSUInteger) numberOfSignals {
    LOG_CURRENT_METHOD;
    return [_signals count];
}

#pragma mark -
#pragma CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    LOG( @"peripheral: %@ advertisementData: %@ RSSI: %@", peripheral, advertisementData, RSSI );

    NSInteger addedIndex = [_peripherals addPeripheral:peripheral]; // retain
    if (addedIndex >= 0) {
        [[NSNotificationCenter defaultCenter]
           postNotificationName:IRKitDidDiscoverPeripheralNotification
                         object:nil
                       userInfo:@{
                         @"addedIndex": [NSNumber numberWithInteger:addedIndex]
                       }];
    }

    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
     The reason for this is that the CFUUID .UUID property of CBPeripheral
     here is null the first time an unkown (never connected before in any app)
     peripheral is connected. So therefore we connect to all peripherals we find.
     */

    peripheral.delegate = self;
    [_manager connectPeripheral:peripheral
                        options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES }];
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
        NSInteger addedIndex = [_peripherals addPeripheral:peripheral]; // retain
        if (addedIndex >= 0) {
            [[NSNotificationCenter defaultCenter]
                postNotificationName:IRKitDidDiscoverPeripheralNotification
                              object:nil
                            userInfo:@{
                              @"addedIndex": [NSNumber numberWithInteger:addedIndex]
                            }];
        }

        peripheral.delegate = self;
        [_manager connectPeripheral:peripheral
                            options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES }];
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    LOG( @"peripheral: %@, RSSI: %@", peripheral, peripheral.RSSI );

    // iOS 6.0 bug workaround : connect to device before displaying UUID !
    // The reason for this is that the CFUUID .UUID property of CBPeripheral
    // here is null the first time an unkown (never connected before in any app)
    // peripheral is connected. So therefore we connect to all peripherals we find.
    [peripheral setDelegate:self];
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
    
}

#pragma mark -
#pragma CBPeripheralDelegate

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

        // TODO: delete this row
        // discover characterstics for all services (just interested now)
        [peripheral discoverCharacteristics:nil forService:service];

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

    for (CBCharacteristic *characteristic in service.characteristics)
    {
        LOG( @"characteristic: %@, UUID: %@, value: %@, descriptors: %@, properties: %@, isNotifying: %d, isBroadcasted: %d",
            characteristic, characteristic.UUID, characteristic.value, characteristic.descriptors, NSStringFromCBCharacteristicProperty(characteristic.properties), characteristic.isNotifying, characteristic.isBroadcasted );
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

    if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            /* Read device name */
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
            {
                [peripheral readValueForCharacteristic:characteristic];
                LOG(@"Found a Device Name Characteristic, RSSI: %@", peripheral.RSSI);
            }
        }
    }

    // org.bluetooth.service.device_information
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            // Read manufacturer name
            // 2a29: org.bluetooth.characteristic.manufacturer_name_string
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
            {
                [peripheral readValueForCharacteristic:characteristic];
                LOG(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }
}

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
- (void) peripheral:(CBPeripheral *)aPeripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
              error:(NSError *)error
{
    LOG( @"peripheral: %@ charactristic: %@ value: %@ error: %@", aPeripheral, characteristic, characteristic.value, error);
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
    {
        NSString * deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Device Name = %@", deviceName);
    }
    // 2a29: org.bluetooth.characteristic.manufacturer_name_string
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
    {
        NSString* manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Manufacturer Name = %@", manufacturer);
    }
}

@end
