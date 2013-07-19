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
@property (nonatomic) CBCentralManager *manager;
@property (nonatomic) CBPeripheral *peripheral;
@property (nonatomic) BOOL shouldReadIRData;
@property (nonatomic) BOOL wantsToConnect;

@end

@implementation IRPeripheral

- (id) initWithManager: (CBCentralManager*) manager {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    
    _writeQueue       = nil;
    _manager          = manager;
    _peripheral       = nil;
    _shouldReadIRData = NO;
    _wantsToConnect   = NO;
    
    _UUID             = nil;
    _customizedName   = nil;
    _foundDate        = [NSDate date];
    _receivedCount    = IRPERIPHERAL_RECEIVED_COUNT_UNKNOWN; // on memory should be enough
    _authorized       = NO;
    
    _manufacturerName = nil;
    _modelName        = nil;
    _hardwareRevision = nil;
    _firmwareRevision = nil;
    _softwareRevision = nil;
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

- (void)setManager:(CBCentralManager*)manager {
    _manager = manager;
}

- (void)setPeripheral:(CBPeripheral *)peripheral {
    _peripheral = peripheral;
    _UUID       = _peripheral.UUID;

    if ( ! _writeQueue ) {
        _writeQueue = [[IRWriteOperationQueue alloc] init];
    }
    [_writeQueue setSuspended: ! self.isReady];
}

- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral {
    return [self.foundDate compare: otherPeripheral.foundDate];
}

- (void)didDiscoverWithAdvertisementData:(NSDictionary *)advertisementData
                                    RSSI:(NSNumber *)rssi {
    LOG_CURRENT_METHOD;

    NSData *data = advertisementData[CBAdvertisementDataManufacturerDataKey];
    uint8_t receivedCount = 0;
    if (data) {
        [data getBytes:&receivedCount
                 range:(NSRange){0,1}];
    }
    LOG( @"peripheral: %@ receivedCount: %d", _peripheral, receivedCount );

    UIApplicationState state = [[UIApplication sharedApplication] applicationState];

    // connect when:
    // * app in foreground and not authorized = we need to connect to receive auth c12c's indication
    // * app in foreground and peripheral's received count has changed = peripheral should have received IR data, we're gonna read it
    // * we're in background and retainConnectionInBackground is YES
    if ( (state == UIApplicationStateActive) && ! _authorized ) {
        [self connect];
    }
    else if ( (state == UIApplicationStateActive) &&
             (_receivedCount != IRPERIPHERAL_RECEIVED_COUNT_UNKNOWN) &&
             (_receivedCount != (uint16_t)receivedCount) ) {
        _shouldReadIRData = YES;
        [self connect];
    }
    else if ( [IRKit sharedInstance].retainConnectionInBackground &&
             (state != UIApplicationStateActive) ) {
        [self connect];
    }
    _receivedCount = receivedCount;
}

- (void) didRetrieve {
    LOG_CURRENT_METHOD;
    if (_wantsToConnect) {
        [_manager connectPeripheral:_peripheral
                            options:@{ CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES }];
    }
}

- (void) didConnect {
    LOG_CURRENT_METHOD;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:IRKitDidConnectPeripheralNotification
     object:self
     userInfo:nil];
    
    [_peripheral discoverServices:nil];
}

- (void) disconnect {
    [_writeQueue setSuspended: YES];

    if ([IRKit sharedInstance].retainConnectionInBackground && _authorized) {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateBackground ||
            state == UIApplicationStateInactive) {
            // don't disconnect in the background
            LOG( @"dont disconnect in the background" );
            return;
        }
    }
    LOG( @"will disconnect" );
    [_manager cancelPeripheralConnection: _peripheral];
}

- (void) didDisconnect {
    LOG_CURRENT_METHOD;
    
    [_writeQueue setSuspended: YES];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:IRKitDidDisconnectPeripheralNotification
     object:self
     userInfo:nil];
}

- (void) writeValueInBackground:(NSData *)value
      forCharacteristicWithUUID:(CBUUID *)characteristicUUID
              ofServiceWithUUID:(CBUUID *)serviceUUID
                     completion:(void (^)(NSError *))block {
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

- (BOOL) writeValue:(NSData *)value
forCharacteristicWithUUID:(CBUUID *)characteristicUUID
  ofServiceWithUUID:(CBUUID *)serviceUUID {
    LOG_CURRENT_METHOD;
    
    CBCharacteristic *c12c = [IRHelper findCharacteristicInPeripheral:_peripheral
                                                           withCBUUID:characteristicUUID
                                                  inServiceWithCBUUID:serviceUUID];
    if (! c12c) {
        return NO;
    }
    LOG( @"wrote to service: %@ c12c: %@ data: %@", serviceUUID, characteristicUUID, value );
    [_peripheral writeValue:value
          forCharacteristic:c12c
                       type:CBCharacteristicWriteWithResponse];
    return YES;
}

- (NSString*) modelNameAndRevision {
    LOG_CURRENT_METHOD;
    if ( ! _modelName || ! _hardwareRevision || ! _firmwareRevision || ! _softwareRevision ) {
        return @"unknown";
    }
    return [@[_modelName, _hardwareRevision, _firmwareRevision, _softwareRevision] componentsJoinedByString:@"/"];
}

#pragma mark - Private methods

- (void)connect {
    LOG_CURRENT_METHOD;

    if (! _peripheral) {
        _wantsToConnect = YES;
        [_manager retrievePeripherals:@[ (__bridge_transfer id)_UUID ]];
        return;
    }
    if (_peripheral.isConnected) {
        return;
    }
    [_manager connectPeripheral:_peripheral
                        options:@{
        CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES
     }];
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
    
    // org.bluetooth.service.device_information
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            // TODO only read device information on app startup
            [peripheral readValueForCharacteristic:characteristic];
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
            [[IRKit sharedInstance] save];
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
    
    // 2a29: org.bluetooth.characteristic.manufacturer_name_string
    if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_MANUFACTURER_NAME_UUID]) {
        _manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Manufacturer Name = %@", _manufacturerName);
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_MODEL_NAME_UUID]) {
        _modelName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Model Name = %@", _modelName);
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_HARDWARE_REVISION_UUID]) {
        _hardwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Hardware Revision = %@", _hardwareRevision);
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_FIRMWARE_REVISION_UUID]) {
        _firmwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Firmware Revision = %@", _firmwareRevision);
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_SOFTWARE_REVISION_UUID]) {
        _softwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Software Revision = %@", _softwareRevision);
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
    [coder encodeObject:[IRHelper stringFromCFUUID:_UUID]
                 forKey:@"u"];
    [coder encodeObject:_customizedName forKey:@"c"];
    [coder encodeObject:_foundDate      forKey:@"f"];
    [coder encodeObject:[NSNumber numberWithBool:_authorized] forKey:@"a"];

    // d: Device information
    [coder encodeObject:_manufacturerName forKey:@"dm"];
    [coder encodeObject:_modelName        forKey:@"do"];
    [coder encodeObject:_hardwareRevision forKey:@"dh"];
    [coder encodeObject:_firmwareRevision forKey:@"df"];
    [coder encodeObject:_softwareRevision forKey:@"ds"];
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [self init];
    if (self) {
        NSString *u       = [coder decodeObjectForKey:@"u"];
        _UUID             = CFUUIDCreateFromString(nil, (CFStringRef)u);
        _customizedName   = [coder decodeObjectForKey:@"c"];
        _foundDate        = [coder decodeObjectForKey:@"f"];
        _authorized       = [[coder decodeObjectForKey:@"a"] boolValue];
        
        _manufacturerName = [coder decodeObjectForKey:@"dm"];
        _modelName        = [coder decodeObjectForKey:@"do"];
        _hardwareRevision = [coder decodeObjectForKey:@"dh"];
        _firmwareRevision = [coder decodeObjectForKey:@"df"];
        _softwareRevision = [coder decodeObjectForKey:@"ds"];
        
        _peripheral       = nil;
        
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
