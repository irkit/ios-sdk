//
//  IRSignalSendOperation.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRSignal.h"

@interface IRSignalSendOperation : NSOperation

@property (nonatomic) IRSignal *signal;

-(id)initWithSignal:(IRSignal*)signal
         completion:(void (^)(NSError *error))completion;

@end
