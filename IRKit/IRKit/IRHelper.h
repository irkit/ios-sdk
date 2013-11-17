#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IRHelper : NSObject

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block;
+ (NSString*) sha1:(NSArray*) array;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageInResourceNamed:(NSString*)name;

+ (void)loadImage:(NSString*)url
completionHandler:(void (^)(NSHTTPURLResponse *response, UIImage *image, NSError *error)) handler;

@end
