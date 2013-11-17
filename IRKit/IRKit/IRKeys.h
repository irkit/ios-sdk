//
//  IRKeys.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/07.
//
//

#import <Foundation/Foundation.h>

NS_ENUM( uint8_t, IRSecurityType ) {
    IRSecurityTypeNone = 0,
    IRSecurityTypeWEP  = 2,
    IRSecurityTypeWPA  = 4,
    IRSecurityTypeWPA2 = 8,
};

@interface IRKeys : NSObject

@property (nonatomic) NSString* ssid;
@property (nonatomic) NSString* password;
@property (nonatomic) enum IRSecurityType security;
@property (nonatomic) NSString* key;

- (NSString*) securityTypeString;
+ (NSString*) securityTypeStringOf: (enum IRSecurityType) security;
+ (BOOL) isPassword:(NSString*)password validForSecurityType:(enum IRSecurityType)securityType;

@end
