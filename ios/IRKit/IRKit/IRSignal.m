//
//  IRPeripheral.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignal.h"
#import "IRHelper.h"
#import "IRKit.h"

@interface IRSignal ()

@property (nonatomic) NSString* uuid;

@end

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
    
    _receivedDate = [NSDate date];
    return self;
}

- (NSString*)name {
    LOG_CURRENT_METHOD;
    return _name ? _name : @"unknown name";
}

- (IRPeripheral*)peripheral {
    LOG_CURRENT_METHOD;
    if ( _peripheral ) {
        return _peripheral;
    }
    if ( _uuid ) {
        // we can't use [IRKit sharedInstance] inside our initWithCoder
        // so we temporary save peripheral.UUID in _uuid
        // and recover IRPeripheral afterwards (here)
        _peripheral = [[IRKit sharedInstance].peripherals IRPeripheralForUUID:_uuid];
        return _peripheral;
    }
    return nil;
}

#pragma mark -
#pragma NSKeyedArchiving

- (void)encodeWithCoder:(NSCoder*)coder {
    LOG_CURRENT_METHOD;
    [coder encodeObject:_name                       forKey:@"n"];
    [coder encodeObject:_data                       forKey:@"d"];
    [coder encodeObject:_receivedDate               forKey:@"r"];
    [coder encodeObject:[IRHelper stringFromCFUUID: _peripheral.peripheral.UUID]
                 forKey:@"u"];
}

- (id)initWithCoder:(NSCoder*)coder {
    LOG_CURRENT_METHOD;
    self = [super init];
    if (self) {
        _name         = [coder decodeObjectForKey:@"n"];
        _data         = [coder decodeObjectForKey:@"d"];
        _receivedDate = [coder decodeObjectForKey:@"r"];
        _uuid         = [coder decodeObjectForKey:@"u"];
        
        if ( ! _name ) {
            _name = @"unknown";
        }
        if ( ! _receivedDate ) {
            _receivedDate = [NSDate date];
        }
    }
    return self;
}

@end
