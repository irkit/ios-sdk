//
//  IRKit.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRKit.h"
#import "IRFunc.h" // private
#import "IRPeripherals.h"

@interface IRKit ()

@property (nonatomic, strong) CBCentralManager* manager;
@property (nonatomic, strong) CBPeripheral* peripheral;
@property (nonatomic, strong) IRPeripherals *peripherals;
@property (nonatomic, strong) NSMutableArray* signals; // array of IRSignal

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
    [self loadFromPersistentStore];

    return self;
}

- (void) startScan {
    LOG_CURRENT_METHOD;
    
//    [_manager scanForPeripheralsWithServices:@[ IRKIT_SERVICE_UUID_STRING ]
//                                     options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
    // find anything
    [_manager scanForPeripheralsWithServices:nil
                                     options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
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

- (void)loadFromPersistentStore {
    LOG_CURRENT_METHOD;
    
    
}

#pragma mark -
#pragma CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    LOG( @"peripheral: %@ advertisementData: %@ RSSI: %@", peripheral, advertisementData, RSSI );

    if( ![_peripherals containsObject:peripheral] ) {
        [_peripherals addObject:peripheral];
    }

    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
     The reason for this is that the CFUUID .UUID property of CBPeripheral
     here is null the first time an unkown (never connected before in any app)
     peripheral is connected. So therefore we connect to all peripherals we find.
     */

    peripheral.delegate = self;
    [_manager connectPeripheral:peripheral
                        options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES }];

    /* Retreive already known devices */
    if(autoConnect) {
        [_manager retrievePeripherals:[NSArray arrayWithObject: (id)peripheral.UUID]];
    }

}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    LOG_CURRENT_METHOD;

}

- (void)centralManager:(CBCentralManager *)central
didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    LOG_CURRENT_METHOD;

}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 */
- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals {
    LOG( @"peripherals: %@", peripherals);

//    [self stopScan];

    /* If there are any known devices, automatically connect to the 1st one. */
    if([peripherals count] >=1)
    {
        self.peripheral = [peripherals objectAtIndex:0];
        LOG( @"peripheral %@ RSSI: %@", _peripheral.UUID, _peripheral.RSSI );
        [_manager connectPeripheral:_peripheral
                            options: @{ CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES }];
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    LOG( @"peripheral: %@, RSSI: %@", peripheral, peripheral.RSSI );

    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    LOG( @"peripheral: %@ error: %@", peripheral, error);
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
    for (CBService *service in peripheral.services)
    {
        LOG(@"Service found with UUID: %@ RSSI: %@", service.UUID, peripheral.RSSI);

        /* Heart Rate Service */
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }

        /* Device Information Service */
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }

        /* GAP (Generic Access Profile) for Device Name */
        if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
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
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            /* Set notification on heart rate measurement */
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
            {
                [peripheral setNotifyValue:YES
                          forCharacteristic:characteristic];
                LOG(@"Found a Heart Rate Measurement Characteristic");
            }
            /* Read body sensor location */
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
            {
                [peripheral readValueForCharacteristic:characteristic];
                LOG(@"Found a Body Sensor Location Characteristic");
            }

            /* Write heart rate control point */
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])
            {
                uint8_t val = 1;
                NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                [peripheral writeValue:valData forCharacteristic:characteristic
                                   type:CBCharacteristicWriteWithResponse];
            }
        }
    }

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

    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            /* Read manufacturer name */
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
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /* Updated value for heart rate measurement received */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
    {
        if( (characteristic.value)  || !error )
        {
            /* Update UI with heart rate data */
            //            [self updateWithHRMData:characteristic.value];
        }
    }
    /* Value for body sensor location received */
    else  if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
    {
        NSData * updatedValue = characteristic.value;
        LOG( @"updatedValue: %@", updatedValue);
    }
    /* Value for device Name received */
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]])
    {
        NSString * deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Device Name = %@", deviceName);
    }
    /* Value for manufacturer name received */
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
    {
        NSString* manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Manufacturer Name = %@", manufacturer);
    }
}

@end
