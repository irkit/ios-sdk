//
//  ONSignals.m
//  One
//
//  Created by Masakazu Ohtsuka on 2013/07/26.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "ONSignals.h"

@implementation ONSignals

+ (instancetype) sharedInstance {
    static ONSignals* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[ONSignals alloc] init];
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

- (void)save {
    LOG_CURRENT_METHOD;

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:_signals.data
          forKey:@"signals"];
    [d synchronize];
}

- (void)sendSequentiallyWithCompletion:(void (^)(NSError *))completion {
    LOG_CURRENT_METHOD;
    [_signals sendSequentiallyWithCompletion:^(NSError *error) {
        LOG( @"sent error:", error );
    }];
}

@end
