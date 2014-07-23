#import "Log.h"
#import "IRPeripheral.h"
#import "IRKit.h"
#import "IRHelper.h"
#import "IRConst.h"
#import "IRHTTPClient.h"
#import "IRReachability.h"

@interface IRPeripheral ()

@property (nonatomic) IRReachability *reachability;

@end

@implementation IRPeripheral

- (instancetype)init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if (!self) {
        return nil;
    }
    _hostname       = nil;
    _customizedName = nil;
    _foundDate      = [NSDate date];
    _deviceid       = nil;

    // from HTTP response Server header
    // eg: "Server: IRKit/1.3.0.73.ge6e8514"
    // "IRKit" is modelName
    // "1.3.0.73.ge6e8514" is version
    _modelName = nil;
    _version   = nil;
    _regdomain = nil;

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

- (void)dealloc {
    LOG_CURRENT_METHOD;
}

- (BOOL)hasDeviceID {
    return _deviceid ? YES : NO;
}

- (void)setHostname:(NSString *)hostname {
    LOG_CURRENT_METHOD;
    _hostname = hostname;

    [self startReachability];
}

- (NSString *)local_hostname {
    return [NSString stringWithFormat: @"%@.local", _hostname];
}

- (BOOL)isReachableViaWifi {
    return _reachability.isReachableViaWiFiAndDirect;
}

- (void)getKeyWithCompletion:(void (^)())successfulCompletion {
    LOG_CURRENT_METHOD;

    [IRHTTPClient getDeviceIDFromHost: _hostname
                       withCompletion:^(NSHTTPURLResponse *res_local, NSHTTPURLResponse *res_internet, NSString *deviceid, NSError *error) {
        LOG(@"res_local: %@, res_internet: %@, key: %@, err: %@", res_local, res_internet, deviceid, error);
        if (deviceid) {
            _deviceid = deviceid;
            NSDictionary *hostInfo = [IRHTTPClient hostInfoFromResponse: res_local];
            if (hostInfo) {
                _modelName = hostInfo[ @"modelName" ];
                _version   = hostInfo[ @"version" ];
            }
            successfulCompletion();
        }
    }];
}

- (void)getModelNameAndVersionWithCompletion:(void (^)())successfulCompletion {
    LOG_CURRENT_METHOD;

    // GET /message only to see Server header
    [IRHTTPClient fetchHostInfoOf: _hostname withCompletion:^(NSHTTPURLResponse *res, NSDictionary *info, NSError *error) {
        if (info) {
            _modelName = info[ @"modelName" ];
            _version   = info[ @"version" ];
            successfulCompletion();
        }
    }];
}

- (NSComparisonResult)compareByFirstFoundDate:(IRPeripheral *)otherPeripheral {
    return [self.foundDate compare: otherPeripheral.foundDate];
}

- (NSString *)modelNameAndRevision {
    LOG_CURRENT_METHOD;
    if (!_modelName || !_version) {
        return @"unknown";
    }
    return [@[_modelName, _version] componentsJoinedByString : @"/"];
}

- (NSString *)iconURL {
    return [NSString stringWithFormat: @"%@/images/model/%@.png", STATICENDPOINT_BASE, _modelName ? _modelName: @"IRKit" ];
}

- (NSDictionary *)asDictionary {
    return @{
               @"hostname"       : _hostname       ? _hostname : [NSNull null],
               @"customizedName" : _customizedName ? _customizedName : [NSNull null],
               @"foundDate"      : _foundDate      ? [NSNumber numberWithDouble: [_foundDate timeIntervalSince1970]] : [NSNull null],
               @"deviceid"       : _deviceid       ? _deviceid : [NSNull null],
               @"modelName"      : _modelName      ? _modelName : [NSNull null],
               @"version"        : _version        ? _version : [NSNull null],
               @"regdomain"      : _regdomain      ? _regdomain : [NSNull null],
    };
}

- (void)inflateFromDictionary:(NSDictionary *)dictionary {
    if (dictionary[@"foundDate"]) {
        _foundDate = [NSDate dateWithTimeIntervalSince1970: [(NSNumber*)dictionary[@"foundDate"] doubleValue]];
    }
    for (NSString *key in @[ @"hostname", @"customizedName", @"deviceid", @"modelName", @"version", @"regdomain" ]) {
        if (dictionary[ key ]) {
            [self setValue: dictionary[ key ] forKey: key];
        }
    }
}

#pragma mark - Private methods

- (void)startReachability {
    LOG_CURRENT_METHOD;

    if (_hostname) {
        _reachability = [IRReachability reachabilityWithHostname: self.local_hostname];
    }
}

#pragma mark - NSKeyedArchiving

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject: _hostname forKey: @"hostname"];
    [coder encodeObject: _customizedName forKey: @"customizedName"];
    [coder encodeObject: _foundDate forKey: @"foundDate"];
    [coder encodeObject: _deviceid forKey: @"deviceid"];
    [coder encodeObject: _modelName forKey: @"modelName"];
    [coder encodeObject: _version forKey: @"version"];
    [coder encodeObject: _regdomain forKey: @"regdomain"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    LOG_CURRENT_METHOD;
    self = [self init];
    if (!self) {
        return nil;
    }
    _hostname       = [coder decodeObjectForKey: @"hostname"];
    _customizedName = [coder decodeObjectForKey: @"customizedName"];
    _foundDate      = [coder decodeObjectForKey: @"foundDate"];
    _deviceid       = [coder decodeObjectForKey: @"deviceid"];
    _modelName      = [coder decodeObjectForKey: @"modelName"];
    _version        = [coder decodeObjectForKey: @"version"];
    _regdomain      = [coder decodeObjectForKey: @"regdomain"];

    [self startReachability];

    return self;
}

@end
