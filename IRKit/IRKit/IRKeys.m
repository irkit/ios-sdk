//
//  IRKeys.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/07.
//
//

#import "Log.h"
#import "IRKeys.h"
#import "CRC8.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#define MORSE_DELIMITER          @"/"

// SSID is max 32 bytes
// see 7.3.1.2 of IEEE 802.11
#define MAX_WIFI_SSID_LENGTH     32

// password is max 63 characters
// see H.4.1 of IEEE 802.11
#define MAX_WIFI_PASSWORD_LENGTH 63

// it's an UUID (without '-')
#define MAX_KEY_LENGTH           32

struct KeysCRCed
{
    uint8_t security;
    char ssid    [MAX_WIFI_SSID_LENGTH     + 1];
    char password[MAX_WIFI_PASSWORD_LENGTH + 1];
    bool wifi_is_set;
    bool wifi_was_valid;

    char temp_key[MAX_KEY_LENGTH           + 1];
} __attribute__((packed));

@implementation IRKeys

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    // defaults to WPA2
    _security = IRSecurityTypeWPA2;
    return self;
}

- (NSString *)securityTypeString {
    return [IRKeys securityTypeStringOf: _security];
}

+ (NSString *)securityTypeStringOf:(enum IRSecurityType)security {
    switch (security) {
    case IRSecurityTypeNone:
        return @"None";

    case IRSecurityTypeWEP:
        return @"WEP";

    case IRSecurityTypeWPA2:
    default:
        return @"WPA/WPA2";
    }
}

+ (BOOL)isPassword:(NSString *)password validForSecurityType:(enum IRSecurityType)securityType {
    if (securityType == IRSecurityTypeWEP) {
        NSUInteger length = password.length;
        // WEP passwords can only be 5 or 13 in ASCII, 10 or 26 in HEX
        if (length == 5 || length == 13 || length == 10 || length == 26) {
            // TODO invalidate if length is valid for ASCII but password is HEX or vise versa
            return YES;
        }
        return NO;
    }
    return YES;
}

// [0248]/#{SSID}/#{Password}/#{Key}/#{RegDomain}//////#{CRC}
- (NSString *)morseStringRepresentation {
    LOG_CURRENT_METHOD;

    NSString *security = [self securityStringRepresentation];
    LOG(@"security: %@", security);
    LOG(@"ssid: %@", _ssid);
    LOG(@"password: %@", _password);
    LOG(@"devicekey: %@", _devicekey);

    NSString *ssidHex     = [self ssidStringRepresentation];
    NSString *passwordHex = [self passwordStringRepresentation];

    struct KeysCRCed crced;
    memset(&crced, 0, sizeof(struct KeysCRCed) );
    strncpy(crced.ssid,     [_ssid UTF8String],      strnlen([_ssid UTF8String], 33));
    strncpy(crced.password, [self passwordUTF8String],  strnlen([self passwordUTF8String], 64));
    strncpy(crced.temp_key, [_devicekey UTF8String], strnlen([_devicekey UTF8String], 33));
    crced.wifi_is_set    = true;
    crced.wifi_was_valid = false;
    crced.security       = _security;
    uint8_t crc      = crc8((uint8_t *)&crced, sizeof(struct KeysCRCed));
    NSString *crcHex = [NSString stringWithFormat: @"%02x", crc];

    NSArray *components = @[
        security,
        ssidHex,
        passwordHex,
        _devicekey,
        [self regdomain],
        @"",     // reserved2
        @"",     // reserved3
        @"",     // reserved4
        @"",     // reserved5
        @"",     // reserved6
        crcHex,
                          ];
    return [[components componentsJoinedByString: @"/"] uppercaseString];
}

- (void)setKeys:(NSDictionary *)keys {
    LOG(@"keys: %@", keys);
    _deviceid  = keys[ @"deviceid" ];
    _devicekey = keys[ @"devicekey" ];
}

- (BOOL)keysAreSet {
    return (_deviceid && _devicekey);
}

- (NSString *)regdomain {
    NSString *regdomain;

    // from carrier
    // might be incorrect if roaming?
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier              = [netInfo subscriberCellularProvider];
    NSString *countryCode           = [[carrier isoCountryCode] uppercaseString];

    if (!countryCode) {
        // this is what user explicitly sets in settings app
        // which defaults to US
        countryCode = [[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode] uppercaseString];
    }
    if ([countryCode isEqualToString: @"JP"]) {
        regdomain = @"2"; // TELEC
    }
    // Regulatory Domains by Country
    // http://www.summitdata.com/Documents/Regulatory_Domains.pdf
    else if ([@[@"CA", @"MX", @"US", @"AU", @"HK", @"IN", @"MY", @"NZ", @"PH", @"TW", @"RU", @"AR", @"BR", @"CL", @"CO", @"CR", @"DO", @"DM", @"EC", @"PA", @"PY", @"PE", @"PR", @"VE"] containsObject : countryCode]) {
        regdomain = @"0"; // FCC
    }
    else {
        regdomain = @"1"; // ETSI
    }
    return regdomain;
}

#pragma mark - Private

- (NSString *)securityStringRepresentation {
    switch (_security) {
    case IRSecurityTypeNone:
        return @"0";

    case IRSecurityTypeWEP:
        return @"2";

    case IRSecurityTypeWPA2:
    default:
        return @"8";
    }
}

- (NSString *)ssidStringRepresentation {
    const char *utf8 = [_ssid UTF8String];

    // ssids should be limited to 32bytes
    NSMutableString *ret = @"".mutableCopy;

    for (int i = 0; i < strnlen(utf8, 33); i++) {
        [ret appendString: [NSString stringWithFormat: @"%02x", utf8[i] & 0xFF]];
    }
    return ret;
}

// if security type is WEP,
// IRKit(GS1011MIPS) expects HEX representation of passwords,
// and we transfer it's HEX representation,
// so it's double ASCII -> HEX transformed.
// ex: when actual password is: "abcde", send "6162636465" to GS,
//     send "36313632363336343635" over morse (limitedAP)
// WEP ASCII passwords can be 5 or 13 letters
- (NSString *)passwordStringRepresentation {
    const char *utf8 = [self passwordUTF8String];

    // passwords should be limited to 63bytes
    NSMutableString *ret = @"".mutableCopy;

    for (int i = 0; i < strnlen(utf8, 64); i++) {
        [ret appendString: [NSString stringWithFormat: @"%02x", utf8[i] & 0xFF]];
    }
    return ret;
}

- (const char *)passwordUTF8String {
    if ( (_security == IRSecurityTypeWEP) &&
         ((_password.length == 5) ||
          (_password.length == 13)) )
    {
        return [[self wepPasswordStringRepresentation] UTF8String];
    }
    else {
        return [_password UTF8String];
    }
}

- (NSString *)wepPasswordStringRepresentation {
    const char *utf8 = [_password UTF8String];

    // passwords should be limited to 63bytes
    NSMutableString *ret = @"".mutableCopy;

    for (int i = 0; i < strnlen(utf8, 64); i++) {
        [ret appendString: [NSString stringWithFormat: @"%02x", utf8[i] & 0xFF]];
    }
    return ret;
}

@end
