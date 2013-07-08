//
//  IRWriteOperation.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRPeripheral.h"

@interface IRWriteOperation : NSOperation

- (void) didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
                                  error:(NSError *)error;

+ (IRWriteOperation*) operationToPeripheral:(IRPeripheral*)peripheral
                                   withData:(NSData*)data
                  forCharacteristicWithUUID:(CBUUID*)characteristicUUID
                          ofServiceWithUUID:(CBUUID*)serviceUUID
                                 completion:(void (^)(NSError *error))completion;

@end
