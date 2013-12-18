#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *IRLocalizedString(NSString* key, NSString* comment);

@interface IRHelper : NSObject

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block;
+ (void) enumerateSubviewsOfRootView:(UIView*)view usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
+ (NSBundle*)resources;
+ (UIFont*)fontWithSize:(CGFloat)size;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageInResourceNamed:(NSString*)name;

@end
