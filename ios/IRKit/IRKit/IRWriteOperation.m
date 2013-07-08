//
//  IRWriteOperation.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRWriteOperation.h"
#import "IRConst.h"
#import "IRHelper.h"

@interface IRWriteOperation ()

@property BOOL isExecuting;
@property BOOL isFinished;

@property (nonatomic) IRPeripheral *peripheral;
@property (nonatomic) NSData *data;
@property (nonatomic) CBUUID *characteristicUUID;
@property (nonatomic) CBUUID *serviceUUID;
@property (nonatomic, copy) void (^completion)(NSError *error);

@end

@implementation IRWriteOperation

- (void) start {
    LOG_CURRENT_METHOD;
    
    self.isExecuting = YES;
    self.isFinished  = NO;

    if ( ! _peripheral.isReady ) {
        // should be connected when started
        dispatch_async( dispatch_get_main_queue(),
                       ^{
                           NSError *error = [NSError errorWithDomain:IRKIT_ERROR_DOMAIN
                                                                code:IRKIT_ERROR_CODE_DISCONNECTED
                                                            userInfo:nil];
                           _completion( error );
                           self.isExecuting = NO;
                           self.isFinished  = YES;
                       });
        return;
    }
    for (CBService *service in _peripheral.peripheral.services) {
        LOG( @"service: %@, UUID: %@", service, service.UUID );
        
        if ( [IRHelper CBUUID: service.UUID
              isEqualToCBUUID: _serviceUUID]) {
            for (CBCharacteristic *c12c in service.characteristics) {
                LOG( @"characteristic: %@, UUID: %@, value: %@, descriptors: %@, properties: %@, isNotifying: %d, isBroadcasted: %d",
                    c12c, c12c.UUID, c12c.value, c12c.descriptors, NSStringFromCBCharacteristicProperty(c12c.properties), c12c.isNotifying, c12c.isBroadcasted );

                if ([IRHelper CBUUID: c12c.UUID
                     isEqualToCBUUID: _characteristicUUID]) {
                    LOG( @"wrote to service: %@ c12c: %@ data: %@", _serviceUUID, _characteristicUUID, _data );
                    [_peripheral.peripheral writeValue:_data
                                     forCharacteristic:c12c
                                                  type:CBCharacteristicWriteWithResponse];
                    return;
                }
            }
        }
    }
    dispatch_async( dispatch_get_main_queue(), ^{
        LOG( @"not found service: %@ c12c: %@", _serviceUUID, _characteristicUUID );
        NSError *error = [NSError errorWithDomain:IRKIT_ERROR_DOMAIN
                                             code:IRKIT_ERROR_CODE_C12C_NOT_FOUND
                                         userInfo:nil];
        _completion( error );
        self.isExecuting = NO;
        self.isFinished  = YES;
    });
}

- (void) didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
                                  error:(NSError *)error {
    LOG_CURRENT_METHOD;
    dispatch_async( dispatch_get_main_queue(), ^{
        _completion( error );
        self.isExecuting = NO;
        self.isFinished  = YES;
    });
}

+ (IRWriteOperation*) operationToPeripheral:(IRPeripheral*) peripheral
                                   withData:(NSData*)data
                  forCharacteristicWithUUID:(CBUUID*)characteristicUUID
                          ofServiceWithUUID:(CBUUID*)serviceUUID
                                 completion:(void (^)(NSError *error))completion {
    LOG_CURRENT_METHOD;
    IRWriteOperation *op = [[IRWriteOperation alloc] init];
    op.peripheral         = peripheral;
    op.data               = data;
    op.characteristicUUID = characteristicUUID;
    op.serviceUUID        = serviceUUID;
    op.completion         = completion;
    return op;
}

#pragma mark - KVO

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"isExecuting"] || [key isEqualToString:@"isFinished"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

- (BOOL)isConcurrent
{
    return NO;
}

@end
