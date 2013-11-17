//
//  IRKeys.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/07.
//
//

#import "IRKeys.h"

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

@end
