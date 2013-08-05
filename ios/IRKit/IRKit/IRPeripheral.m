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
#import "IRPeripheralWriteOperationQueue.h"
#import "IRPeripheralWriteOperation.h"

@interface IRPeripheral ()

@property (nonatomic) IRPeripheralWriteOperationQueue *writeQueue;
@property (nonatomic) CBCentralManager *manager;
@property (nonatomic) CBPeripheral *peripheral; // hide from public
@property (nonatomic) BOOL shouldReadIRData;
@property (nonatomic) BOOL shouldRefreshDeviceInformation;
@property (nonatomic) BOOL wantsToConnect;

@end

@implementation IRPeripheral

- (id) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    _writeQueue       = nil;
    _peripheral       = nil;
    _shouldReadIRData = NO;

    // only read device information on app startup
    // we won't release this object, so initializing with YES will do
    _shouldRefreshDeviceInformation = YES;
    _wantsToConnect   = NO;

    _UUID             = nil;
    _customizedName   = nil;
    _foundDate        = [NSDate date];
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
        _writeQueue = [[IRPeripheralWriteOperationQueue alloc] init];
    }
    [_writeQueue setSuspended: ! self.isReady];
}

- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral {
    return [self.foundDate compare: otherPeripheral.foundDate];
}

- (void)didDiscoverWithAdvertisementData:(NSDictionary *)advertisementData
                                    RSSI:(NSNumber *)rssi {
    LOG( @"peripheral: %@", _peripheral );

    UIApplicationState state = [[UIApplication sharedApplication] applicationState];

    // connect when:
    // * app in foreground
    // * we're in background and retainConnectionInBackground is YES
    if ( state == UIApplicationStateActive ) {
        [self connect];
    }
    else if ( [IRKit sharedInstance].retainConnectionInBackground ) {
        [self connect];
    }
}

- (void) didRetrieve {
    LOG_CURRENT_METHOD;

    UIApplicationState state = [[UIApplication sharedApplication] applicationState];

    if (_wantsToConnect) {
        _wantsToConnect = NO;
        [self connect];
    }
    else if ( state == UIApplicationStateActive ) {
        [self connect];
    }
}

- (void) didConnect {
    LOG_CURRENT_METHOD;
    
    if (! [self canReadAllCharacteristics]) {
        [_peripheral discoverServices:nil];
        return;
    }
    [self didBecomeReady];
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

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:IRKitDidDisconnectPeripheralNotification
                                                            object:self
                                                          userInfo:nil];
    });
}

- (void) writeValueInBackground:(NSData *)value
      forCharacteristicWithUUID:(CBUUID *)characteristicUUID
              ofServiceWithUUID:(CBUUID *)serviceUUID
                     completion:(void (^)(NSError *))block {
    LOG( @"service: %@ c12c: %@ value: %@", serviceUUID, characteristicUUID, value );
    [self startDisconnectTimerIfBackground];
    
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
    
    IRPeripheralWriteOperation *op = [IRPeripheralWriteOperation operationToPeripheral:self
                                                          withData:value
                                         forCharacteristicWithUUID:characteristicUUID
                                                 ofServiceWithUUID:serviceUUID
                                                        completion:^(NSError *error) {
                                                            // runs in main thread
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

- (void) didBecomeReady {
    LOG_CURRENT_METHOD;

    [_writeQueue setSuspended: ! self.isReady];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:IRKitDidConnectPeripheralNotification
                                                            object:self
                                                          userInfo:nil];
    });

    CBCharacteristic *auth =
    [IRHelper findCharacteristicInPeripheral:_peripheral
                                  withCBUUID:IRKIT_CHARACTERISTIC_AUTHORIZATION_UUID
                         inServiceWithCBUUID:IRKIT_SERVICE_UUID];
    [_peripheral setNotifyValue:YES
              forCharacteristic:auth];

    CBCharacteristic *unread =
    [IRHelper findCharacteristicInPeripheral:_peripheral
                                  withCBUUID:IRKIT_CHARACTERISTIC_UNREAD_STATUS_UUID
                         inServiceWithCBUUID:IRKIT_SERVICE_UUID];
    LOG( @"registering for notifications on unread status" );
    [_peripheral setNotifyValue:YES
              forCharacteristic:unread];

    // when uninstalled and re-installed after _authorized is YES
    // _authorized is initialized to NO,
    // so we try to read it, and peripheral responds with YES
    LOG( @"are we authorized?" );
    [_peripheral readValueForCharacteristic:auth];

    if ( _authorized && _shouldReadIRData ) {
        LOG( @"read IR data" );
        _shouldReadIRData = NO;
        CBCharacteristic *irdata =
        [IRHelper findCharacteristicInPeripheral:_peripheral
                                      withCBUUID:IRKIT_CHARACTERISTIC_IR_DATA_UUID
                             inServiceWithCBUUID:IRKIT_SERVICE_UUID];
        [_peripheral readValueForCharacteristic:irdata];
    }

    if (_shouldRefreshDeviceInformation) {
        // org.bluetooth.service.device_information
        CBService *deviceInformation
        = [IRHelper findServiceInPeripheral:_peripheral
                                   withUUID:IRKIT_SERVICE_DEVICE_INFORMATION];
        for (CBCharacteristic *characteristic in deviceInformation.characteristics) {
            [_peripheral readValueForCharacteristic:characteristic];
        }
        _shouldRefreshDeviceInformation = NO;
    }
}

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

- (void) startDisconnectTimerIfBackground {
    LOG_CURRENT_METHOD;

    [self cancelDisconnectTimer];

    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if ( state == UIApplicationStateActive ) {
        // retain connection
    }
    else {
        // disconnect after interval
        // regarding that we might want to continuously write to this peripheral
        [self performSelector:@selector(disconnect)
                   withObject:nil
                   afterDelay:5.];
    }
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
    [self startDisconnectTimerIfBackground];

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
    [self startDisconnectTimerIfBackground];
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        LOG( @"characteristic: %@, UUID: %@, value: %@, descriptors: %@, properties: %@, isNotifying: %d, isBroadcasted: %d",
            characteristic, characteristic.UUID, characteristic.value, characteristic.descriptors, NSStringFromCBCharacteristicProperty(characteristic.properties), characteristic.isNotifying, characteristic.isBroadcasted );
    }

    if ([IRHelper CBUUID:service.UUID
         isEqualToCBUUID:IRKIT_SERVICE_UUID]) {
        [self didBecomeReady];
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
    [self startDisconnectTimerIfBackground];

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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:IRKitDidAuthorizePeripheralNotification
                                                                        object:self];
                });
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

            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:IRKitDidReceiveSignalNotification
                                                                    object:self
                                                                  userInfo:@{IRKitSignalUserInfoKey: signal}];
            });
        }
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_UNREAD_STATUS_UUID]) {
        if (_authorized) {
            CBCharacteristic *irdata = [IRHelper findCharacteristicInPeripheral:_peripheral
                                                                     withCBUUID:IRKIT_CHARACTERISTIC_IR_DATA_UUID
                                                            inServiceWithCBUUID:IRKIT_SERVICE_UUID];
            [_peripheral readValueForCharacteristic:irdata];
        }
    }

    BOOL shouldSave = NO;
    // 2a29: org.bluetooth.characteristic.manufacturer_name_string
    if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_MANUFACTURER_NAME_UUID]) {
        shouldSave = YES;
        _manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Manufacturer Name = %@", _manufacturerName);
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_MODEL_NAME_UUID]) {
        shouldSave = YES;
        _modelName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Model Name = %@", _modelName);
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_HARDWARE_REVISION_UUID]) {
        shouldSave = YES;
        _hardwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Hardware Revision = %@", _hardwareRevision);
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_FIRMWARE_REVISION_UUID]) {
        shouldSave = YES;
        _firmwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Firmware Revision = %@", _firmwareRevision);
    }
    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_SOFTWARE_REVISION_UUID]) {
        shouldSave = YES;
        _softwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        LOG(@"Software Revision = %@", _softwareRevision);
    }

    if (shouldSave) {
        [[IRKit sharedInstance] save];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    LOG( @"peripheral: %@ charactristic: %@ UUID: %@ error: %@", peripheral, characteristic, characteristic.UUID, error);
    [self startDisconnectTimerIfBackground];

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
    if (! self) {
        return nil;
    }
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
    return self;
}

@end
