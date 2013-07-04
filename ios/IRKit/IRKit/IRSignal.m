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

- (NSComparisonResult) compareByReceivedDate: (IRSignal*) otherSignal {
    return [self.receivedDate compare: otherSignal.receivedDate];
}

- (NSString*) uniqueID {
    LOG_CURRENT_METHOD;
    return [IRHelper sha1: _data];
}

- (void)sendWithCompletion: (void (^)(NSError* error))block {
    LOG_CURRENT_METHOD;
    [self writeIRDataWithCompletion: ^(NSError *error) {
        if ( ! error ) {
            [self writeControlPointWithCompletion: ^(NSError *error) {
                if ( ! error ) {
                    block(nil); // send succeeded!
                    return;
                }
                block(error);
            }];
            return;
        }
        block(error);
    }];
}

- (void)writeIRDataWithCompletion: (void (^)(NSError *error))block {
    LOG_CURRENT_METHOD;
    
    [self.peripheral writeData:[self signalAsNSData]
     forCharacteristicWithUUID:IRKIT_CHARACTERISTIC_IR_DATA_UUID
             ofServiceWithUUID:IRKIT_SERVICE_UUID
                    completion:^(NSError *error) {
                        block(error);
                    }];
}

- (void)writeControlPointWithCompletion: (void (^)(NSError *error))block {
    LOG_CURRENT_METHOD;
    
    [self.peripheral writeData: [self controlPointSendValue]
     forCharacteristicWithUUID: IRKIT_CHARACTERISTIC_CONTROL_POINT_UUID
             ofServiceWithUUID: IRKIT_SERVICE_UUID
                    completion: ^(NSError *error) {
                        block(error);
                    }];
}

#pragma mark -
#pragma mark Private methods

- (NSData*) signalAsNSData {
    LOG_CURRENT_METHOD;
    if ( ! _data.count ) {
        return nil;
    }
    // uint16_t value for each NSArray entry
    NSMutableData *ret = [NSMutableData dataWithCapacity: _data.count * 2];
    [_data enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        uint16_t interval = [obj shortValue];
        [ret appendData: [NSData dataWithBytes:&interval
                                        length:2]];
    }];
    LOG( @" ret: %@", ret);
    return ret;
}

- (NSData*) controlPointSendValue {
    LOG_CURRENT_METHOD;
    uint8_t value = IRKIT_CONTROL_POINT_VALUE_SEND;
    return [NSData dataWithBytes:&value length:1];
}

#pragma mark -
#pragma mark Accessors

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

    _uuid = _uuid ? _uuid
                  : [IRHelper stringFromCFUUID:self.peripheral.peripheral.UUID];
    
    [coder encodeObject:_name         forKey:@"n"];
    [coder encodeObject:_data         forKey:@"d"];
    [coder encodeObject:_receivedDate forKey:@"r"];
    [coder encodeObject:_uuid         forKey:@"u"];
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
