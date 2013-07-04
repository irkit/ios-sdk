//
//  IRPeripheral.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripheral.h"
#import "IRKit.h"

@interface IRPeripheral ()

@property (nonatomic, copy) void (^writeResponseBlock)(NSError *error);

@end

@implementation IRPeripheral

- (id) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    _authorized       = NO;
    _shouldReadIRData = NO;
    // on memory should be enough
    _receivedCount = 0;

    return self;
}

- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral {
    return [self.foundDate compare: otherPeripheral.foundDate];
}

- (void) writeData: (NSData*)value
 forCharacteristicWithUUID: (CBUUID*)characteristicUUID
         ofServiceWithUUID: (CBUUID*)serviceUUID
                completion: (void (^)(NSError *error))block {
    LOG( @"service: %@ c12c: %@ value: %@", serviceUUID, characteristicUUID, value );
    NSError *error;
    
    if ( _writeResponseBlock ) {
        // TODO already writing??
        block( error );
    }
    if ( ! _peripheral ) {
        // TODO no peripheral?
    }
    if ( ! _peripheral.isConnected ) {
        // TODO not connected
        
    }
    for (CBService *service in _peripheral.services) {
        if ( [service.UUID isEqual:serviceUUID]) {
            for (CBCharacteristic *c12c in service.characteristics) {
                if ([c12c.UUID isEqual:characteristicUUID]) {
                    _writeResponseBlock = block;
                    [_peripheral writeValue:value
                          forCharacteristic:c12c
                                       type:CBCharacteristicWriteWithResponse];
                    return;
                }
            }
        }
    }
    // TODO no c12c found
    block( error );
}

- (void) restartDisconnectTimer {
    LOG_CURRENT_METHOD;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // disconnect after interval
    // regarding that we might want to continuously write to this peripheral
    [self performSelector:@selector(disconnect)
               withObject:nil
               afterDelay:1.];
}

- (void) disconnect {
    LOG_CURRENT_METHOD;
    [[IRKit sharedInstance] disconnectPeripheral: self];
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
                if ( ! _authorized ) {
                    LOG( @"are we authorized?" );
                    [peripheral setNotifyValue:YES
                             forCharacteristic:characteristic];
                    [peripheral readValueForCharacteristic:characteristic];
                    shouldStayConnected = YES;
                }
            }
            else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_IR_DATA_UUID]) {
                if ( _authorized && _shouldReadIRData ) {
                    LOG( @"read IR data" );
                    _shouldReadIRData = NO;
                    [peripheral readValueForCharacteristic:characteristic];
                    shouldStayConnected = YES;
                }
            }
        }
        
        if ( ! shouldStayConnected ) {
            [self restartDisconnectTimer];
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
    
    if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_AUTHORIZATION_UUID]) {
        NSData *value = characteristic.value;
        unsigned char authorized = 0;
        [value getBytes:&authorized length:1];
        LOG( @"authorized: %d", authorized );
        
        if (authorized) {
            _authorized = YES;
            [[IRKit sharedInstance].peripherals save];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:IRKitPeripheralAuthorizedNotification
             object:nil];
            [self restartDisconnectTimer];
        }
        else {
            // retain connection while waiting for user to press auth switch
        }
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_IR_DATA_UUID]) {
        NSData *value = characteristic.value;
        LOG( @"value.length: %d", value.length );
        IRSignal *signal = [[IRSignal alloc] initWithData: value];
        signal.peripheral = self;
        if (! [[IRKit sharedInstance].signals memberOfSignals:signal]) {
            [[IRKit sharedInstance].signals addSignalsObject:signal];
            [[IRKit sharedInstance].signals save];
        }
        [self restartDisconnectTimer];
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
    [self restartDisconnectTimer];
}

#pragma mark -
#pragma NSKeyedArchiving

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:_customizedName forKey:@"c"];
    [coder encodeObject:_isPaired       forKey:@"p"];
    [coder encodeObject:_foundDate      forKey:@"f"];
    [coder encodeObject:[NSNumber numberWithBool:_authorized] forKey:@"a"];
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [super init];
    if (self) {
        _customizedName = [coder decodeObjectForKey:@"c"];
        _isPaired       = [coder decodeObjectForKey:@"p"];
        _foundDate      = [coder decodeObjectForKey:@"f"];
        _authorized     = [[coder decodeObjectForKey:@"a"] boolValue];
        _peripheral     = nil;
        
        if ( ! _customizedName ) {
            _customizedName = @"unknown";
        }
        if ( ! _isPaired ) {
            _isPaired = @NO;
        }
        if ( ! _foundDate ) {
            _foundDate = [NSDate date];
        }
    }
    return self;
}

@end
