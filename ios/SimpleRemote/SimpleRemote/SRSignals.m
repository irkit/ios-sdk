//
//  SRSignals.m
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/07/26.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "SRSignals.h"

@implementation SRSignals

+ (instancetype) sharedInstance {
    static SRSignals* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[SRSignals alloc] init];
    });
    return instance;
}

- (id) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if (! self) {
        return nil;
    }

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSData *data = [d objectForKey: @"signals"];
    _signals = [[IRSignals alloc] init];
    [_signals loadFromData:data];

    return self;
}

- (void)setSignals:(IRSignals *)signals {
    LOG_CURRENT_METHOD;

    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground ||
        state == UIApplicationStateInactive) {
        _updatedInBackground = YES;
    }
    _signals = signals;
}

- (void)sendSequentially {
    LOG_CURRENT_METHOD;
    [_signals sendSequentially];
}

@end
