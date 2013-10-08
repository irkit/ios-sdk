//
//  IRMorsePlayerOperationQueue.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/10/08.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "Log.h"
#import "IRMorsePlayerOperationQueue.h"
#import "IRMorsePlayerOperation.h"

@interface IRMorsePlayerOperationQueue ()
@end

@implementation IRMorsePlayerOperationQueue

- (id) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }

    [self setMaxConcurrentOperationCount:1];
    return self;
}

#pragma mark - Private methods

@end
