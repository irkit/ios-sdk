//
//  IRPeripheral.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripheral.h"
#import "IRKit.h"
#import "IRHelper.h"
#import "IRWriteOperationQueue.h"
#import "IRWriteOperation.h"

@interface IRPeripheral ()

@property (nonatomic, copy) void (^writeResponseBlock)(NSError *error);
@property (nonatomic) IRWriteOperationQueue *writeQueue;

@end

@implementation IRPeripheral

- (id) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    _foundDate        = [NSDate date];
    _receivedCount    = IRPERIPHERAL_RECEIVED_COUNT_UNKNOWN; // on memory should be enough
    _authorized       = NO;
    _shouldReadIRData = NO;
    _writeQueue       = nil;
    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
}

- (BOOL)isReady {
    // TODO use state on iOS7
    return _peripheral ? _peripheral.isConnected && [self canReadAllCharacteristics]
                       : NO;
}

- (void)connect {
    LOG_CURRENT_METHOD;

    _wantsToConnect = YES;
    [[IRKit sharedInstance] retrieveKnownPeripherals];
}

- (void)setPeripheral:(CBPeripheral *)peripheral {
    // LOG_CURRENT_METHOD;
    
    _peripheral = peripheral;

    if ( ! _writeQueue ) {
        _writeQueue = [[IRWriteOperationQueue alloc] init];
    }
    [_writeQueue setSuspended: ! self.isReady];
}

- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral {
    return [self.foundDate compare: otherPeripheral.foundDate];
}

- (void) writeData: (NSData*)value
 forCharacteristicWithUUID: (CBUUID*)characteristicUUID
         ofServiceWithUUID: (CBUUID*)serviceUUID
                completion: (void (^)(NSError *error))block {
    LOG( @"service: %@ c12c: %@ value: %@", serviceUUID, characteristicUUID, value );
    [self restartDisconnectTimer];
    
    NSError *error;
    if ( ! _writeQueue || ! _peripheral ) {
        error = [NSError errorWithDomain:IRKIT_ERROR_DOMAIN
                                    code:IRKIT_ERROR_CODE_NOT_READY
                                userInfo:nil];
        block(error);
        return;
    }
    
    if ( ! _peripheral.isConnected ) {
        [self connect];
    }
    
    IRWriteOperation *op = [IRWriteOperation operationToPeripheral:self
                                                          withData:value
                                         forCharacteristicWithUUID:characteristicUUID
                                                 ofServiceWithUUID:serviceUUID
                                                        completion:^(NSError *error) {
                                                        block(error);
                                                    }];
    [_writeQueue setSuspended: ! self.isReady];
    [_writeQueue addOperation:op];
}

- (void) cancelDisconnectTimer {
    LOG_CURRENT_METHOD;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void) restartDisconnectTimer {
    LOG_CURRENT_METHOD;
    
    [self cancelDisconnectTimer];

    // disconnect after interval
    // regarding that we might want to continuously write to this peripheral
    [self performSelector:@selector(disconnect)
               withObject:nil
               afterDelay:5.];
}

- (void) didDisconnect {
    LOG_CURRENT_METHOD;
    
    [_writeQueue setSuspended: YES];
}

#pragma mark - Private methods

- (void) disconnect {
    LOG_CURRENT_METHOD;

    [_writeQueue setSuspended: YES];
    [[IRKit sharedInstance] disconnectPeripheral: self];
}

- (BOOL) canReadAllCharacteristics {
    LOG_CURRENT_METHOD;
    
    int found = 0;
    for (CBService *service in _peripheral.services) {
        if (! [IRHelper CBUUID:service.UUID
               isEqualToCBUUID:IRKIT_SERVICE_UUID] ) {
            continue;
        }
        for (CBCharacteristic *c12c in service.characteristics) {
            for (CBCharacteristic *expected_c12c in IRKIT_CHARACTERISTICS) {
                if ([IRHelper CBUUID:c12c.UUID
                     isEqualToCBUUID:expected_c12c]) {
                    found ++;
                }
            }
        }
    }
    if ( found >= [IRKIT_CHARACTERISTICS count]) {
        return YES;
    }
    return NO;
}

#pragma mark - CBPeripheralDelegate

/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error
{
    LOG( @"peripheral: %@ error: %@", peripheral, error);
    [self restartDisconnectTimer];

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
    [self restartDisconnectTimer];

    [_writeQueue setSuspended: ! self.isReady];

    for (CBCharacteristic *characteristic in service.characteristics)
    {
        LOG( @"characteristic: %@, UUID: %@, value: %@, descriptors: %@, properties: %@, isNotifying: %d, isBroadcasted: %d",
            characteristic, characteristic.UUID, characteristic.value, characteristic.descriptors, NSStringFromCBCharacteristicProperty(characteristic.properties), characteristic.isNotifying, characteristic.isBroadcasted );
    }
    
    if ([service.UUID isEqual:IRKIT_SERVICE_UUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_AUTHORIZATION_UUID]) {
                // when uninstalled and re-installed after _authorized is YES
                // _authorized is initialized to NO,
                // so we try to read it, and peripheral responds with YES
                LOG( @"are we authorized?" );
                [peripheral setNotifyValue:YES
                         forCharacteristic:characteristic];
                [peripheral readValueForCharacteristic:characteristic];
            }
            else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_IR_DATA_UUID]) {
                if ( _authorized && _shouldReadIRData ) {
                    LOG( @"read IR data" );
                    _shouldReadIRData = NO;
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
            else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_UNREAD_STATUS_UUID]) {
                LOG( @"registering for notifications on unread status" );
                [peripheral setNotifyValue:YES
                         forCharacteristic:characteristic];
            }
        }
    }
    
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
    [self restartDisconnectTimer];

    if (error) {
        // TODO error handling
        return;
    }
    
    // disconnect when authorized
    // we connect only when we need to
    
    if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_AUTHORIZATION_UUID]) {
        NSData *value = characteristic.value;
        unsigned char authorized = 0;
        [value getBytes:&authorized length:1];
        LOG( @"authorized: %d", authorized );

        if ( _authorized != authorized ) {
            // authorized state changed
            _authorized = authorized;
            [[IRKit sharedInstance].peripherals save];
            if ( _authorized ) {
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:IRKitDidAuthorizePeripheralNotification
                 object:nil];
            }
        }

        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if ( (state == UIApplicationStateActive) &&
             ! authorized ) {
            // retain connection while waiting for user to press auth switch
            [self cancelDisconnectTimer];
        }
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_IR_DATA_UUID]) {
        NSData *value = characteristic.value;
        LOG( @"value.length: %d", value.length );
        
        if (value.length > 1) {
            // can be 0
            // length: 1 should be invalid ir data
            
            IRSignal *signal = [[IRSignal alloc] initWithData: value];
            signal.peripheral = self;
            
            [[NSNotificationCenter defaultCenter]
                postNotificationName:IRKitDidReceiveSignalNotification
                              object:self
                            userInfo:@{IRKitSignalUserInfoKey: signal}];
        }
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
    [self restartDisconnectTimer];

    [_writeQueue didWriteValueForCharacteristic:characteristic
                                          error:error];
}

#pragma mark - NSKeyedArchiving

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:_customizedName forKey:@"c"];
    [coder encodeObject:_foundDate      forKey:@"f"];
    [coder encodeObject:[NSNumber numberWithBool:_authorized] forKey:@"a"];
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [self init];
    if (self) {
        _customizedName = [coder decodeObjectForKey:@"c"];
        _foundDate      = [coder decodeObjectForKey:@"f"];
        _authorized     = [[coder decodeObjectForKey:@"a"] boolValue];
        _peripheral     = nil;
        
        if ( ! _customizedName ) {
            _customizedName = @"unknown";
        }
        if ( ! _foundDate ) {
            _foundDate = [NSDate date];
        }
    }
    return self;
}

@end
