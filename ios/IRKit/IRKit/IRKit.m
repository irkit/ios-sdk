//
//  IRKit.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRKit.h"

@implementation IRKit {
    CBCentralManager* manager;
    NSMutableArray* peripherals;
    CBPeripheral* peripheral;
}
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

    manager = [[CBCentralManager alloc] initWithDelegate:self
                                                   queue:nil];

    return self;
}

- (void) startScan {
    LOG_CURRENT_METHOD;
    [manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]]
                                    options:nil];
}

- (void) stopScan {
    LOG_CURRENT_METHOD;
    [manager stopScan];
}

#pragma mark -
#pragma CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)_peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    LOG( @"peripheral: %@ advertisementData: %@ RSSI: %@", _peripheral, advertisementData, RSSI );
    
    if( ![peripherals containsObject:_peripheral] ) {
        [peripherals addObject:_peripheral];
    }
    
    /* Retreive already known devices */
    if(autoConnect) {
        [manager retrievePeripherals:[NSArray arrayWithObject: (id)_peripheral.UUID]];
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
didRetrievePeripherals:(NSArray *)_peripherals {
    LOG( @"peripherals: %@", _peripherals);
    
    [self stopScan];
    
    /* If there are any known devices, automatically connect to the 1st one. */
    if([_peripherals count] >=1)
    {
        peripheral = [_peripherals objectAtIndex:0]; // retain peripheral
        LOG( @"peripheral %@ RSSI: %@", peripheral.UUID, peripheral.RSSI );
        [manager connectPeripheral:peripheral
                           options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                               forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)_peripheral {
    LOG( @"peripheral: %@, RSSI: %@", _peripheral, _peripheral.RSSI );
    
    [_peripheral setDelegate:self];
    [_peripheral discoverServices:nil];
    
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    LOG_CURRENT_METHOD;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    LOG( @"state: %d", [central state]);
}

#pragma mark -
#pragma CBPeripheralDelegate

/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)_peripheral
didDiscoverServices:(NSError *)error
{
    for (CBService *service in _peripheral.services)
    {
        LOG(@"Service found with UUID: %@ RSSI: %@", service.UUID, _peripheral.RSSI);
        
        /* Heart Rate Service */
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]])
        {
            [_peripheral discoverCharacteristics:nil forService:service];
        }
        
        /* Device Information Service */
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
        {
            [_peripheral discoverCharacteristics:nil forService:service];
        }
        
        /* GAP (Generic Access Profile) for Device Name */
        if ( [service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
        {
            [_peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void) peripheral:(CBPeripheral *)_peripheral
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
                [_peripheral setNotifyValue:YES
                          forCharacteristic:characteristic];
                LOG(@"Found a Heart Rate Measurement Characteristic");
            }
            /* Read body sensor location */
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
            {
                [_peripheral readValueForCharacteristic:characteristic];
                LOG(@"Found a Body Sensor Location Characteristic");
            }
            
            /* Write heart rate control point */
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])
            {
                uint8_t val = 1;
                NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
                [_peripheral writeValue:valData forCharacteristic:characteristic
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
                [_peripheral readValueForCharacteristic:characteristic];
                LOG(@"Found a Device Name Characteristic, RSSI: %@", _peripheral.RSSI);
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
                [_peripheral readValueForCharacteristic:characteristic];
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
