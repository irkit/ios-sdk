#import "Log.h"
#import "IRSignal.h"
#import "IRHelper.h"
#import "IRKit.h"

@interface IRSignal ()
@end

@implementation IRSignal

- (id)init {
    self = [super init];
    if ( ! self ) { return nil; }
    _frequency = 38; // default
    return self;
}

- (id) initWithDictionary: (NSDictionary*) dictionary {
    LOG_CURRENT_METHOD;
    self = [self init];
    if ( ! self ) { return nil; }

    _name = dictionary[@"name"];
    _data = dictionary[@"data"];
    _frequency = [(NSNumber*)dictionary[@"frequency"] unsignedIntegerValue];
    // receivedDate arrives as a NSNumber of epoch time
    _receivedDate = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"receivedDate"] doubleValue]];
    _hostname = dictionary[@"hostname"];

    return self;
}

- (NSDictionary*)asDictionary {
    LOG_CURRENT_METHOD;
    return @{
             @"name": _name,
             @"data": _data,
             @"frequency": [NSNumber numberWithUnsignedInteger:_frequency],
             @"receivedDate": [NSNumber numberWithDouble:_receivedDate.timeIntervalSince1970],
             @"hostname": _hostname,
             };
}

- (NSComparisonResult) compareByReceivedDate: (IRSignal*) otherSignal {
    return [otherSignal.receivedDate compare: _receivedDate];
}

- (void)sendWithCompletion: (void (^)(NSError *error))block {
    LOG_CURRENT_METHOD;

    [IRHTTPClient postSignal:self
              withCompletion:block];
}

#pragma mark - Accessors

- (IRPeripheral*)peripheral {
    LOG_CURRENT_METHOD;
    if ( _peripheral ) {
        return _peripheral;
    }
    if ( _hostname ) {
        // we can't use [IRKit sharedInstance] inside our initWithCoder (circular call)
        // so we temporary save peripheral.name in _hostname
        // and recover IRPeripheral afterwards (here)
        _peripheral = [[IRKit sharedInstance].peripherals IRPeripheralForName:_hostname];
        return _peripheral;
    }
    return nil;
}

#pragma mark - Private methods

- (void)writeIRDataWithCompletion: (void (^)(NSError *error))block {
    LOG_CURRENT_METHOD;

//    [self.peripheral writeValueInBackground:[self packedSignalAsNSData]
//                  forCharacteristicWithUUID:IRKIT_CHARACTERISTIC_IR_DATA_UUID
//                          ofServiceWithUUID:IRKIT_SERVICE_UUID
//                                 completion:^(NSError *error) {
//                                     block(error);
//                                 }];
}

//- (NSData*) signalAsNSData {
//    LOG_CURRENT_METHOD;
//    if ( ! _data.count ) {
//        return nil;
//    }
//    // uint16_t value for each NSArray entry
//    // signal data is always Little-Endian
//    NSMutableData *ret = [NSMutableData dataWithCapacity: _data.count * 2];
//    [_data enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
//        uint16_t interval = [obj shortValue];
//        [ret appendData: [NSData dataWithBytes:&interval
//                                        length:2]];
//    }];
//    LOG( @" ret: %@", ret);
//    return ret;
//}

#pragma mark - NSKeyedArchiving

- (void)encodeWithCoder:(NSCoder*)coder {
    LOG_CURRENT_METHOD;

    [coder encodeObject:_name         forKey:@"n"];
    [coder encodeObject:_data         forKey:@"d"];
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:_frequency]
                 forKey:@"f"];
    [coder encodeObject:_receivedDate forKey:@"r"];
    [coder encodeObject:self.peripheralUUID
                 forKey:@"u"];
}

- (id)initWithCoder:(NSCoder*)coder {
    LOG_CURRENT_METHOD;
    self = [super init];
    if (self) {
        _name         = [coder decodeObjectForKey:@"n"];
        _data         = [coder decodeObjectForKey:@"d"];
        _frequency    = [(NSNumber*)[coder decodeObjectForKey:@"f"] unsignedIntegerValue];
        _receivedDate = [coder decodeObjectForKey:@"r"];
        _peripheralUUID = [coder decodeObjectForKey:@"u"];
        
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
