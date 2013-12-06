#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *IRLocalizedString(NSString* key, NSString* comment);

@interface IRHelper : NSObject

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block;
+ (NSBundle*)resources;
+ (UIFont*)fontWithSize:(CGFloat)size;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageInResourceNamed:(NSString*)name;

+ (void)loadImage:(NSString*)url
completionHandler:(void (^)(NSHTTPURLResponse *response, UIImage *image, NSError *error)) handler;

@end
