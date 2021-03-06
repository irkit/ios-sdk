//
//  IRKeys.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/11/07.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, IRSecurityType) {
    IRSecurityTypeNone = 0,
    IRSecurityTypeWEP  = 2,
    IRSecurityTypeWPA2 = 8,
};

@interface IRKeys : NSObject

@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *password;
@property (nonatomic) IRSecurityType security;
@property (nonatomic, copy) NSString *deviceid;
@property (nonatomic, copy) NSString *devicekey; // send this to IRKit using morse

- (NSString *)securityTypeString;
+ (NSString *)securityTypeStringOf:(IRSecurityType)security;
+ (BOOL)isPassword:(NSString *)password validForSecurityType:(IRSecurityType)securityType;
- (NSString *)morseStringRepresentation;
- (void)setKeys:(NSDictionary *)keys;
- (BOOL)keysAreSet;
- (NSString *)regdomain;

@end
