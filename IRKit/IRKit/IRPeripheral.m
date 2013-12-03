#import "Log.h"
#import "IRPeripheral.h"
#import "IRKit.h"
#import "IRHelper.h"
#import "IRPeripheralWriteOperationQueue.h"
#import "IRPeripheralWriteOperation.h"
#import "IRConst.h"
#import "IRHTTPClient.h"
#import "Reachability.h"

// read auth characteristic every 0.5sec
#define IRPERIPHERAL_AUTH_POLLING_INTERVAL 0.5

@interface IRPeripheral ()

@property (nonatomic) IRPeripheralWriteOperationQueue *writeQueue;
@property (nonatomic) BOOL shouldReadIRData;
@property (nonatomic) BOOL shouldRefreshDeviceInformation;
@property (nonatomic) BOOL wantsToConnect;
@property (nonatomic) Reachability* reachability;

@end

@implementation IRPeripheral

- (id) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    _writeQueue       = nil;

    _name             = nil;
    _customizedName   = nil;
    _foundDate        = [NSDate date];
    _key              = nil;

    // from HTTP response Server header
    // eg: "Server: IRKit/1.3.0.73.ge6e8514"
    // "IRKit" is modelName
    // "1.3.0.73.ge6e8514" is version
    _modelName        = nil;
    _version          = nil;

    _canResolve       = false;

    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
}

- (BOOL)hasKey {
    return _key ? YES : NO;
}

- (void)setName:(NSString *)name {
    LOG_CURRENT_METHOD;
    _name = name;

    [self startReachability];
}

- (BOOL)isReachableViaWifi {
    return _reachability.isReachableViaWiFi;
}

- (void)getKeyWithCompletion:(void (^)())successfulCompletion {
    LOG_CURRENT_METHOD;

    [IRHTTPClient getKeyFromHost:_name withCompletion:^(NSHTTPURLResponse *res, NSString* key, NSError *err) {
        LOG( @"res: %@, key: %@, err: %@", res, key, err );
        if (key) {
            _key = key;
            NSDictionary* hostInfo = [IRHTTPClient hostInfoFromResponse:res];
            if (hostInfo) {
                _modelName = hostInfo[ @"modelName" ];
                _version   = hostInfo[ @"version" ];
            }
            successfulCompletion();
        }
    }];
}

- (void)getModelNameAndVersionWithCompletion:(void (^)())successfulCompletion {
    LOG_CURRENT_METHOD;

    // GET /message only to see Server header
    [IRHTTPClient getMessageFromHost:_name
                      withCompletion:^(NSHTTPURLResponse *res, NSDictionary *message, NSError *error) {
                          NSDictionary* hostInfo = [IRHTTPClient hostInfoFromResponse:res];
                          if (hostInfo) {
                              _modelName = hostInfo[ @"modelName" ];
                              _version   = hostInfo[ @"version" ];
                          }
                          successfulCompletion();
                      }];
}

- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral {
    return [self.foundDate compare: otherPeripheral.foundDate];
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

//- (void) writeValueInBackground:(NSData *)value
//      forCharacteristicWithUUID:(CBUUID *)characteristicUUID
//              ofServiceWithUUID:(CBUUID *)serviceUUID
//                     completion:(void (^)(NSError *))block {
//    LOG( @"service: %@ c12c: %@ value: %@", serviceUUID, characteristicUUID, value );
//    [self startDisconnectTimerIfBackground];
//
//    NSError *error;
//    if ( ! _writeQueue || ! _peripheral ) {
//        error = [NSError errorWithDomain:IRKIT_ERROR_DOMAIN
//                                    code:IRKIT_ERROR_CODE_NOT_READY
//                                userInfo:nil];
//        block(error);
//        return;
//    }
//
//    if ( ! _peripheral.isConnected ) {
//        [self connect];
//    }
//
//    IRPeripheralWriteOperation *op = [IRPeripheralWriteOperation operationToPeripheral:self
//                                                          withData:value
//                                         forCharacteristicWithUUID:characteristicUUID
//                                                 ofServiceWithUUID:serviceUUID
//                                                        completion:^(NSError *error) {
//                                                            // runs in main thread
//                                                            block(error);
//                                                        }];
//    [_writeQueue setSuspended: ! self.isReady];
//    [_writeQueue addOperation:op];
//}

- (NSString*) modelNameAndRevision {
    LOG_CURRENT_METHOD;
    if ( ! _modelName || ! _version ) {
        return @"unknown";
    }
    return [@[_modelName, _version] componentsJoinedByString:@"/"];
}

- (NSString*)iconURL {
    return [NSString stringWithFormat:@"%@/static/images/model/%@.png", ONURL_BASE, _modelName ? _modelName : @"IRKit" ];
}

- (void)startAuthPolling {
    LOG_CURRENT_METHOD;

    if (! [NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startAuthPolling];
        });
    }

//    _isPollingAuthC12C = YES;

    [self cancelAuthPollingTimer];

//    CBCharacteristic *auth =
//    [IRHelper findCharacteristicInPeripheral:_peripheral
//                                  withCBUUID:IRKIT_CHARACTERISTIC_AUTHENTICATION_UUID
//                         inServiceWithCBUUID:IRKIT_SERVICE_UUID];
//    [_peripheral readValueForCharacteristic:auth];
}

- (void)stopAuthPolling {
    LOG_CURRENT_METHOD;

    if (! [NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAuthPolling];
        });
    }

    [self cancelAuthPollingTimer];

//    _isPollingAuthC12C = NO;
}

#pragma mark - Private methods

- (void) startReachability {
    LOG_CURRENT_METHOD;

    if (_name) {
        if (_reachability) {
            [_reachability stopNotifier];
        }
        _reachability = [Reachability reachabilityWithHostname:_name];
        // we start notifying but don't observe on notifications
        [_reachability startNotifier];
    }
}

- (void) didBecomeReady {
    LOG_CURRENT_METHOD;

    [_writeQueue setSuspended: ! self.hasKey];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:IRKitDidConnectPeripheralNotification
                                                            object:self
                                                          userInfo:nil];
    });

//    CBCharacteristic *unread =
//    [IRHelper findCharacteristicInPeripheral:_peripheral
//                                  withCBUUID:IRKIT_CHARACTERISTIC_UNREAD_STATUS_UUID
//                         inServiceWithCBUUID:IRKIT_SERVICE_UUID];
//    LOG( @"registering for notifications on unread status" );
//    [_peripheral setNotifyValue:YES
//              forCharacteristic:unread];
//
//    CBCharacteristic *auth =
//    [IRHelper findCharacteristicInPeripheral:_peripheral
//                                  withCBUUID:IRKIT_CHARACTERISTIC_AUTHENTICATION_UUID
//                         inServiceWithCBUUID:IRKIT_SERVICE_UUID];

    // when uninstalled and re-installed after _authenticated is YES
    // _authenticated is initialized to NO,
    // so we try to read it, and peripheral responds with YES
//    LOG( @"are we authenticated?" );
//    [_peripheral readValueForCharacteristic:auth];
//
//    if ( _authenticated && _shouldReadIRData ) {
//        LOG( @"read IR data" );
//        _shouldReadIRData = NO;
//        CBCharacteristic *irdata =
//        [IRHelper findCharacteristicInPeripheral:_peripheral
//                                      withCBUUID:IRKIT_CHARACTERISTIC_IR_DATA_UUID
//                             inServiceWithCBUUID:IRKIT_SERVICE_UUID];
//        [_peripheral readValueForCharacteristic:irdata];
//    }
//
//    if (_shouldRefreshDeviceInformation) {
//        // org.bluetooth.service.device_information
//        CBService *deviceInformation
//        = [IRHelper findServiceInPeripheral:_peripheral
//                                   withUUID:IRKIT_SERVICE_DEVICE_INFORMATION];
//        for (CBCharacteristic *characteristic in deviceInformation.characteristics) {
//            [_peripheral readValueForCharacteristic:characteristic];
//        }
//        _shouldRefreshDeviceInformation = NO;
//    }
}


// should call only in main thread
// because performSelector:withObject:afterDelay: is called in main thread
- (void) cancelAuthPollingTimer {
    LOG_CURRENT_METHOD;

    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(startAuthPolling)
                                               object:nil];
}

- (void) startDisconnectTimerIfBackground {
    LOG_CURRENT_METHOD;

    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if ( state == UIApplicationStateActive ) {
        // retain connection
    }
    else {
        // disconnect after interval
        // to not disconnect while continuously writing to this peripheral
        dispatch_async(dispatch_get_main_queue(),^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                     selector:@selector(disconnect)
                                                       object:nil];
            [self performSelector:@selector(disconnect)
                       withObject:nil
                       afterDelay:5.];
        });
    }
}

#pragma mark - CBPeripheralDelegate

/*
 Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
 */
//- (void) peripheral:(CBPeripheral *)aPeripheral
//didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
//              error:(NSError *)error
//{
//    LOG( @"peripheral: %@ charactristic: %@ UUID: %@ value: %@ error: %@", aPeripheral, characteristic, characteristic.UUID, characteristic.value, error);
//    [self startDisconnectTimerIfBackground];
//
//    if (error) {
//        // TODO error handling
//        return;
//    }
//
//    // disconnect when authenticated
//    // we connect only when we need to
//
//    if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_AUTHENTICATION_UUID]) {
//        NSData *value = characteristic.value;
//        unsigned char authenticated = 0;
//        [value getBytes:&authenticated length:1];
//        LOG( @"authenticated: %d", authenticated );
//
//        if ( _authenticated != authenticated ) {
//            // authenticated state changed
//            _authenticated = authenticated;
//            [[IRKit sharedInstance] save];
//            if ( _authenticated ) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[NSNotificationCenter defaultCenter] postNotificationName:IRKitDidAuthenticatePeripheralNotification
//                                                                        object:self];
//                });
//            }
//        }
//
//        if (_isPollingAuthC12C && ! authenticated) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // we don't manage this thread,
//                // it might stop occasionally without calling this selector
//                // so make sure it runs after delay in main thread
//                [self performSelector:@selector(startAuthPolling)
//                           withObject:nil
//                           afterDelay:IRPERIPHERAL_AUTH_POLLING_INTERVAL];
//            });
//        }
//    }
//    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_IR_DATA_UUID]) {
//        NSData *value = characteristic.value;
//        LOG( @"value.length: %d", value.length );
//
//        if (value.length > 1) {
//            // can be 0
//            // length: 1 should be invalid ir data
//
//            IRSignal *signal = [[IRSignal alloc] initWithData: value];
//            signal.peripheral = self;
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:IRKitDidReceiveSignalNotification
//                                                                    object:self
//                                                                  userInfo:@{IRKitSignalUserInfoKey: signal}];
//            });
//        }
//    }
//    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_UNREAD_STATUS_UUID]) {
//        if (_authenticated) {
//            CBCharacteristic *irdata = [IRHelper findCharacteristicInPeripheral:_peripheral
//                                                                     withCBUUID:IRKIT_CHARACTERISTIC_IR_DATA_UUID
//                                                            inServiceWithCBUUID:IRKIT_SERVICE_UUID];
//            [_peripheral readValueForCharacteristic:irdata];
//        }
//    }
//
//    BOOL shouldSave = NO;
//    // 2a29: org.bluetooth.characteristic.manufacturer_name_string
//    if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_MANUFACTURER_NAME_UUID]) {
//        shouldSave = YES;
//        _manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        LOG(@"Manufacturer Name = %@", _manufacturerName);
//    }
//    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_MODEL_NAME_UUID]) {
//        shouldSave = YES;
//        _modelName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        LOG(@"Model Name = %@", _modelName);
//    }
//    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_HARDWARE_REVISION_UUID]) {
//        shouldSave = YES;
//        _hardwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        LOG(@"Hardware Revision = %@", _hardwareRevision);
//    }
//    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_FIRMWARE_REVISION_UUID]) {
//        shouldSave = YES;
//        _firmwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        LOG(@"Firmware Revision = %@", _firmwareRevision);
//    }
//    else if ([characteristic.UUID isEqual:IRKIT_CHARACTERISTIC_SOFTWARE_REVISION_UUID]) {
//        shouldSave = YES;
//        _softwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        LOG(@"Software Revision = %@", _softwareRevision);
//    }
//
//    if (shouldSave) {
//        [[IRKit sharedInstance] save];
//    }
//}

// TODO check if it's the same characteristic we wrote
//- (void)peripheral:(CBPeripheral *)peripheral
//didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
//             error:(NSError *)error
//{
//    LOG( @"peripheral: %@ charactristic: %@ UUID: %@ error: %@", peripheral, characteristic, characteristic.UUID, error);
//    [self startDisconnectTimerIfBackground];
//
//    [_writeQueue didWriteValueForCharacteristic:characteristic
//                                          error:error];
//}

#pragma mark - NSKeyedArchiving

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:_name           forKey:@"name"];
    [coder encodeObject:_customizedName forKey:@"customizedName"];
    [coder encodeObject:_foundDate      forKey:@"foundDate"];
    [coder encodeObject:_key            forKey:@"key"];
    [coder encodeObject:_modelName      forKey:@"modelName"];
    [coder encodeObject:_version        forKey:@"version"];
}

- (id)initWithCoder:(NSCoder*)coder {
    LOG_CURRENT_METHOD;
    self = [self init];
    if (! self) {
        return nil;
    }
    _name             = [coder decodeObjectForKey:@"name"];
    _customizedName   = [coder decodeObjectForKey:@"customizedName"];
    _foundDate        = [coder decodeObjectForKey:@"foundDate"];
    _key              = [coder decodeObjectForKey:@"key"];
    _modelName        = [coder decodeObjectForKey:@"modelName"];
    _version          = [coder decodeObjectForKey:@"version"];

    [self startReachability];

    return self;
}

@end
