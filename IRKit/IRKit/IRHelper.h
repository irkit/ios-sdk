#import <Foundation/Foundation.h>

extern NSString * IRLocalizedString(NSString *key, NSString *comment);

@interface IRHelper : NSObject

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^) (id obj, NSUInteger idx))block;
+ (NSBundle *)resources;
+ (NSString *)localIPAddress;
#if TARGET_OS_IPHONE
+ (NSString *)currentWifiSSID;
#endif // TARGET_OS_IPHONE

@end
