//
//  IRWriteOperation.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRWriteOperation.h"
#import "IRConst.h"

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

    if ( ! _peripheral.isConnected ) {
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
        if ( [service.UUID isEqual:_serviceUUID]) {
            for (CBCharacteristic *c12c in service.characteristics) {
                if ([c12c.UUID isEqual:_characteristicUUID]) {
                    [_peripheral.peripheral writeValue:_data
                                     forCharacteristic:c12c
                                                  type:CBCharacteristicWriteWithResponse];
                    return;
                }
            }
        }
    }
    dispatch_async( dispatch_get_main_queue(), ^{
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
    dispatch_async( dispatch_get_main_queue(), ^{
        _completion( error );
        self.isExecuting = NO;
        self.isFinished  = YES;
    });
}

+ (IRWriteOperation*) operationWithToPeripheral:(IRPeripheral*) peripheral
                                       withData:(NSData*)data
                      forCharacteristicWithUUID: (CBUUID*)characteristicUUID
                              ofServiceWithUUID: (CBUUID*)serviceUUID
                                     completion: (void (^)(NSError *error))completion {
    LOG_CURRENT_METHOD;
    IRWriteOperation *op = [[IRWriteOperation alloc] init];
    op.peripheral         = peripheral;
    op.data               = data;
    op.characteristicUUID = characteristicUUID;
    op.serviceUUID        = serviceUUID;
    op.completion         = completion;
    return op;
}

@end
