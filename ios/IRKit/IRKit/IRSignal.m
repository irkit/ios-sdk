//
//  IRPeripheral.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignal.h"

@implementation IRSignal

- (id) initWithData: (NSData*) newData {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) { return nil; }
    
    // capacity = number of uint16_t in data = data / 2bytes
    NSMutableArray* data_ = [NSMutableArray arrayWithCapacity:newData.length/2];
    
    // uint16_t value is the number of ticks between falling/rising edges of irdata
    NSUInteger location = 0;
    while (location < newData.length) {
        uint16_t interval;
        [newData getBytes: &interval range: (NSRange){.location=location,
                                                      .length=2}];
        location += 2;
        [data_ addObject: [NSNumber numberWithUnsignedShort:interval]];
    }
    _data = data_;
    
    LOG( @"data: %@", _data);
    
    return self;
}

- (NSString*)name {
    LOG_CURRENT_METHOD;
    return @"name";
}

@end
