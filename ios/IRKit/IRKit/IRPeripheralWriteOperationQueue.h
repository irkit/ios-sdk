//
//  IRWriteOperationQueue.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRPeripheralWriteOperationQueue : NSOperationQueue

- (void) didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
                                  error:(NSError *)error;

@end
