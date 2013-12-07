//  our SDK does not pollute global namespace or objects
//  only classes prefixed with IR*

#define LOG_DISABLED 1
#import "Log.h"
#import "IRHelper.h"

NSString *IRLocalizedString(NSString* key, NSString* comment) {
    return [[IRHelper resources] localizedStringForKey:key value:key table:nil];
}

@implementation IRHelper

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

#pragma mark - View related

+ (void) enumerateSubviewsOfRootView:(UIView*)view usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    block(view, 0, 0);
    for (UIView *subview in view.subviews) {
        [self enumerateSubviewsOfRootView:subview usingBlock:block];
    }
}

+ (NSBundle*) resources {
    NSBundle *main      = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];
    return resources;
}

+ (UIFont*)fontWithSize:(CGFloat)size {
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([lang isEqualToString:@"ja"]) {
        return [UIFont fontWithName:@"HiraKakuProN-W3" size:size];
    }
    else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
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

+ (UIImage *)imageInResourceNamed:(NSString*)name {
    NSBundle *bundle = [self resources];
    NSString *path2x = [bundle pathForResource:[NSString stringWithFormat:@"%@@2x",name]
                                        ofType:@"png"];
    UIImage *ret = [UIImage imageWithContentsOfFile:path2x];
    if (! ret) {
        ret = [UIImage imageWithContentsOfFile:[bundle pathForResource:name
                                                                ofType:@"png"]];
    }
    return ret;
}

#pragma mark - Network related

+ (void)loadImage:(NSString*)url
completionHandler:(void (^)(NSHTTPURLResponse *response, UIImage *image, NSError *error)) handler {
    LOG_CURRENT_METHOD;

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
                               UIImage *ret;
                               if (! error) {
                                   ret = [UIImage imageWithData:data];
                               }
                               if (! handler) {
                                   return;
                               }
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   handler((NSHTTPURLResponse*)res,ret,error);
                               });
                           }];
}

@end
