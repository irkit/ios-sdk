//
//  IRWriteOperationQueue.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPeripheralWriteOperationQueue.h"
#import "IRPeripheralWriteOperation.h"

@interface IRPeripheralWriteOperationQueue ()
@end

@implementation IRPeripheralWriteOperationQueue

- (id) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }

    [self setSuspended:YES];
    [self setMaxConcurrentOperationCount:1];
    return self;
}

- (void) didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
                                  error:(NSError *)error {
    LOG_CURRENT_METHOD;
    IRPeripheralWriteOperation *op = self.operations[0];
    if ( ! op ) {
        // inconsistent
        LOG( @"inconsistency..." );
    }
    [op didWriteValueForCharacteristic:characteristic
                                 error:error];
}

#pragma mark - Private methods

@end
