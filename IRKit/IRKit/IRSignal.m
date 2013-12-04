#import "Log.h"
#import "IRSignal.h"
#import "IRHelper.h"
#import "IRKit.h"
#import "IRHTTPClient.h"

@interface IRSignal ()

@property (nonatomic, copy) NSString* hostname;

@end

@implementation IRSignal

- (id)init {
    self = [super init];
    if ( ! self ) { return nil; }
    _frequency = @38; // default
    return self;
}

- (id) initWithDictionary: (NSDictionary*) dictionary {
    LOG_CURRENT_METHOD;
    self = [self init];
    if ( ! self ) { return nil; }

    _name   = dictionary[@"name"];
    _data   = dictionary[@"data"];
    _format = dictionary[@"format"];

    // either name is fine
    _frequency = dictionary[@"freq"];
    if (! _frequency) {
        _frequency = dictionary[@"frequency"];
    }

    // receivedDate arrives as a NSNumber of epoch time
    _receivedDate = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"receivedDate"] doubleValue]];

    _hostname = dictionary[@"hostname"];

    return self;
}

- (id) initWithDictionary: (NSDictionary*) dictionary fromHostname:(NSString*)hostname {
    LOG_CURRENT_METHOD;
    self = [self initWithDictionary:dictionary];
    if ( ! self ) { return nil; }

    if ( ! _receivedDate ) {
        _receivedDate = [NSDate date];
    }
    _hostname = hostname;

    return self;
}

- (NSDictionary*)asDictionary {
    LOG_CURRENT_METHOD;
    return @{
             @"name":         _name,
             @"data":         _data,
             @"format":       _format,
             @"frequency":    _frequency,
             @"receivedDate": [NSNumber numberWithDouble:_receivedDate.timeIntervalSince1970],
             @"hostname":     _hostname,
             };
}

- (NSComparisonResult) compareByReceivedDate: (IRSignal*) otherSignal {
    return [otherSignal.receivedDate compare: _receivedDate];
}

- (void)sendWithCompletion: (void (^)(NSError *error))completion {
    LOG_CURRENT_METHOD;

    [IRHTTPClient postSignal:self
              withCompletion:completion];
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


#pragma mark - NSKeyedArchiving

- (void)encodeWithCoder:(NSCoder*)coder {
    LOG_CURRENT_METHOD;

    [coder encodeObject:_name         forKey:@"n"];
    [coder encodeObject:_data         forKey:@"d"];
    [coder encodeObject:_format       forKey:@"fo"];
    [coder encodeObject:_frequency    forKey:@"f"];
    [coder encodeObject:_receivedDate forKey:@"r"];
    [coder encodeObject:_hostname     forKey:@"h"];
}

- (id)initWithCoder:(NSCoder*)coder {
    LOG_CURRENT_METHOD;
    self = [super init];
    if (self) {
        _name         = [coder decodeObjectForKey:@"n"];
        _data         = [coder decodeObjectForKey:@"d"];
        _format       = [coder decodeObjectForKey:@"fo"];
        _frequency    = [coder decodeObjectForKey:@"f"];
        _receivedDate = [coder decodeObjectForKey:@"r"];
        _hostname     = [coder decodeObjectForKey:@"h"];
        
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
