#import "Log.h"
#import "IRSignal.h"
#import "IRHelper.h"
#import "IRKit.h"
#import "IRHTTPClient.h"

@interface IRSignal ()

@end

@implementation IRSignal

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _frequency = @38; // default
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    LOG_CURRENT_METHOD;
    self = [self init];
    if (!self) {
        return nil;
    }

    [self inflateFromDictionary: dictionary];

    return self;
}

- (NSDictionary *)asDictionary {
    LOG_CURRENT_METHOD;
    NSMutableDictionary *ret = [self asPublicDictionary].mutableCopy;
    [ret addEntriesFromDictionary: @{
         @"name":         _name                    ? _name                    : [NSNull null],
         @"hostname":     _hostname                ? _hostname                : [NSNull null],
         @"deviceid":     self.peripheral.deviceid ? self.peripheral.deviceid : [NSNull null],
         @"custom":       _custom                  ? _custom                  : [NSNull null],
     }];
    return ret;
}

- (NSDictionary *)asSendableDictionary {
    LOG_CURRENT_METHOD;
    NSMutableDictionary *ret = [self asPublicDictionary].mutableCopy;
    [ret addEntriesFromDictionary: @{
         @"name":         _name                    ? _name                    : [NSNull null],
         @"hostname":     _hostname                ? _hostname                : [NSNull null],
     }];
    return ret;
}

- (NSDictionary *)asPublicDictionary {
    LOG_CURRENT_METHOD;
    return @{
               @"data":   _data      ? _data      : [NSNull null],
               @"format": _format    ? _format    : [NSNull null],
               @"freq":   _frequency ? _frequency : [NSNull null],
               @"type":   @"single"
    };
}

#pragma mark - IRSendable protocol

- (void)sendWithCompletion:(void (^)(NSError *error))completion {
    LOG_CURRENT_METHOD;

    [IRHTTPClient postSignal: self
              withCompletion: completion];
}

#pragma mark - Accessors

- (IRPeripheral *)peripheral {
    LOG_CURRENT_METHOD;
    if (_peripheral) {
        return _peripheral;
    }
    if (_hostname) {
        // we can't use [IRKit sharedInstance] inside our initWithCoder (circular call)
        // so we temporary save peripheral.name in _hostname
        // and recover IRPeripheral afterwards (here)
        _peripheral = [[IRKit sharedInstance].peripherals peripheralWithName: _hostname];
        return _peripheral;
    }
    return nil;
}

#pragma mark - Private methods

- (void)inflateFromDictionary:(NSDictionary *)dictionary {
    if (dictionary[ @"message" ]) {
        [self inflateFromDictionary: dictionary[@"message"]];
    }

    if (dictionary[@"name"]) {
        _name = dictionary[@"name"];
    }
    if (dictionary[@"data"]) {
        _data = dictionary[@"data"];
    }
    if (dictionary[@"format"]) {
        _format = dictionary[@"format"];
    }

    // either name is fine
    if (dictionary[@"freq"]) {
        _frequency = dictionary[@"freq"];
    }
    if (dictionary[@"frequency"]) {
        _frequency = dictionary[@"frequency"];
    }

    if (dictionary[@"hostname"]) {
        _hostname = dictionary[@"hostname"];
    }
    if (dictionary[@"custom"]) {
        _custom = dictionary[@"custom"];
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject: _name forKey: @"n"];
    [coder encodeObject: _data forKey: @"d"];
    [coder encodeObject: _format forKey: @"fo"];
    [coder encodeObject: _frequency forKey: @"f"];
    [coder encodeObject: _custom forKey: @"c"];
    [coder encodeObject: _hostname forKey: @"h"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name      = [coder decodeObjectForKey: @"n"];
        _data      = [coder decodeObjectForKey: @"d"];
        _format    = [coder decodeObjectForKey: @"fo"];
        _frequency = [coder decodeObjectForKey: @"f"];
        _custom    = [coder decodeObjectForKey: @"c"];
        _hostname  = [coder decodeObjectForKey: @"h"];
    }
    return self;
}

@end
