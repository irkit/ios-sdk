//
//  IRKeys.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/07.
//
//

#import "Log.h"
#import "IRKeys.h"
#include "CRC8.h"

#define MORSE_DELIMITER @"/"

// SSID is max 32 bytes
// see 7.3.1.2 of IEEE 802.11
#define MAX_WIFI_SSID_LENGTH     32

// password is max 63 characters
// see H.4.1 of IEEE 802.11
#define MAX_WIFI_PASSWORD_LENGTH 63

// it's an UUID
#define MAX_KEY_LENGTH           36

struct KeysCRCed
{
    uint8_t    security;
    char       ssid    [MAX_WIFI_SSID_LENGTH     + 1];
    char       password[MAX_WIFI_PASSWORD_LENGTH + 1];
    bool       wifi_is_set;
    bool       wifi_was_valid;

    char       temp_key[MAX_KEY_LENGTH           + 1];
} __attribute__ ((packed));

@implementation IRKeys

- (instancetype) init {
    self = [super init];
    if ( ! self ) { return nil; }

    // defaults to WPA2
    _security = IRSecurityTypeWPA2;
    return self;
}

- (NSString*) securityTypeString {
    return [IRKeys securityTypeStringOf:_security];
}

+ (NSString*) securityTypeStringOf: (enum IRSecurityType) security {
    switch (security) {
        case IRSecurityTypeNone:
            return @"None";
        case IRSecurityTypeWEP:
            return @"WEP";
        case IRSecurityTypeWPA:
            return @"WPA";
        case IRSecurityTypeWPA2:
        default:
            return @"WPA2";
    }
}

+ (BOOL) isPassword:(NSString*)password validForSecurityType:(enum IRSecurityType)securityType {
    // TODO
    return 1;
}

// [0248]/#{SSID}/#{Password}/#{Key}/#{CRC}
- (NSString*) morseStringRepresentation {
    LOG_CURRENT_METHOD;

    NSString *security    = [self securityStringRepresentation];
    NSString *ssidHex     = [self ssidStringRepresentation];
    NSString *passwordHex = [self passwordStringRepresentation];
    NSString *keyHex      = [self pairedkeyStringRepresentation];
    
    struct KeysCRCed crced;
    memset( &crced, 0, sizeof(struct KeysCRCed) );
    strncpy( crced.ssid,     [_ssid UTF8String],      strnlen([_ssid UTF8String],33));
    strncpy( crced.password, [_password UTF8String],  strnlen([_password UTF8String],64));
    strncpy( crced.temp_key, [_pairedkey UTF8String], strnlen([_pairedkey UTF8String], 37));
    crced.wifi_is_set     = true;
    crced.wifi_was_valid  = false;
    crced.security        = _security;
    uint8_t crc           = crc8((uint8_t*)&crced, sizeof(struct KeysCRCed));
    NSString *crcHex      = [NSString stringWithFormat:@"%02x", crc];

    NSArray *components = @[
        security,
        ssidHex,
        passwordHex,
        keyHex,
        crcHex,
    ];
    return [components componentsJoinedByString:@"/"];
}

- (void) setKeys: (NSArray*) keys {
    LOG( @"keys: %@", keys );
    _mykey     = keys[0];
    _pairedkey = keys[1];
}

#pragma mark - Private

- (NSString*) securityStringRepresentation {
    switch (_security) {
        case IRSecurityTypeNone:
            return @"0";
        case IRSecurityTypeWEP:
            return @"2";
        case IRSecurityTypeWPA:
            return @"4";
        case IRSecurityTypeWPA2:
        default:
            return @"8";
    }
}

- (NSString*) ssidStringRepresentation {
    const char *utf8 = [_ssid UTF8String];

    // ssids should be limited to 32bytes
    NSMutableString *ret = @"".mutableCopy;
    for (int i=0; i<strnlen(utf8,33); i++) {
        [ret appendString: [NSString stringWithFormat:@"%02x", utf8[i]]];
    }
    return ret;
}

- (NSString*) passwordStringRepresentation {
    const char *utf8 = [_password UTF8String];

    // passwords should be limited to 63bytes
    NSMutableString *ret = @"".mutableCopy;
    for (int i=0; i<strnlen(utf8,64); i++) {
        [ret appendString: [NSString stringWithFormat:@"%02x", utf8[i]]];
    }
    return ret;
}

- (NSString*) pairedkeyStringRepresentation {
    const char *utf8 = [_pairedkey UTF8String];

    // keys should be limited to 36bytes
    NSMutableString *ret = @"".mutableCopy;
    for (int i=0; i<strnlen(utf8,37); i++) {
        [ret appendString: [NSString stringWithFormat:@"%02x", utf8[i]]];
    }
    return ret;
}

@end
