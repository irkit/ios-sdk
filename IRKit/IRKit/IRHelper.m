//  our SDK does not pollute global namespace or objects
//  only classes prefixed with IR*

#define LOG_DISABLED 1
#import "Log.h"
#import "IRHelper.h"
#include <ifaddrs.h>
#include <arpa/inet.h>


NSString * IRLocalizedString(NSString *key, NSString *comment) {
    return [[IRHelper resources] localizedStringForKey: key value: key table: nil];
}

@implementation IRHelper

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: [array count]];

    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject: block(obj, idx)];
    }];
    return result;
}

#pragma mark - Network related

// thanks to http://stackoverflow.com/questions/6807788/how-to-get-ip-address-of-iphone-programatically
+ (NSString *)localIPAddress {
    NSString *address          = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr  = NULL;
    int success                = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String: temp_addr->ifa_name] isEqualToString: @"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String: inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - View related

+ (void)enumerateSubviewsOfRootView:(UIView *)view usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    block(view, 0, 0);
    for (UIView *subview in view.subviews) {
        [self enumerateSubviewsOfRootView: subview usingBlock: block];
    }
}

+ (NSBundle *)resources {
    NSBundle *main      = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath: [main pathForResource: @"IRKit"
                                                                   ofType: @"bundle"]];

    return resources;
}

+ (UIFont *)fontWithSize:(CGFloat)size {
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex: 0];

    if ([lang isEqualToString: @"ja"]) {
        return [UIFont fontWithName: @"HiraKakuProN-W3" size: size];
    }
    else {
        return [UIFont fontWithName: @"HelveticaNeue-Light" size: size];
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (UIImage *)imageInResourceNamed:(NSString *)name {
    NSBundle *bundle = [self resources];
    NSString *path2x = [bundle pathForResource: [NSString stringWithFormat: @"%@@2x", name]
                                        ofType: @"png"];
    UIImage *ret = [UIImage imageWithContentsOfFile: path2x];

    if (!ret) {
        ret = [UIImage imageWithContentsOfFile: [bundle pathForResource: name
                                                                 ofType: @"png"]];
    }
    return ret;
}

@end
