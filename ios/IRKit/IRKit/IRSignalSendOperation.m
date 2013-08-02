//
//  IRWriteOperation.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignalSendOperation.h"
#import "IRConst.h"
#import "IRHelper.h"

@interface IRSignalSendOperation ()

@property BOOL isExecuting;
@property BOOL isFinished;

@property (nonatomic) IRPeripheral *peripheral;
@property (nonatomic) NSData *data;
@property (nonatomic) CBUUID *characteristicUUID;
@property (nonatomic) CBUUID *serviceUUID;
@property (nonatomic, copy) void (^completion)(NSError *error);

@end

@implementation IRSignalSendOperation

- (id)initWithSignal:(IRSignal *)signal
          completion:(void (^)(NSError *error))completion {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    _signal = signal;
    _completion = completion;
    return self;
}

- (void) start {
    LOG_CURRENT_METHOD;

    self.isExecuting = YES;
    self.isFinished  = NO;

    [_signal sendWithCompletion:^(NSError *error) {
        _completion(error);
        self.isExecuting = NO;
        self.isFinished  = YES;
    }];
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
