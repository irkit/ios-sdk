//  our SDK does not pollute global namespace or objects
//  only classes prefixed with IR*

#define LOG_DISABLED 1
#import "Log.h"
#import "IRHelper.h"

@implementation IRHelper

+ (NSArray *)mapObjects:(NSArray *)array usingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[array count]];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

#pragma mark - View related

+ (NSBundle*) resources {
    NSBundle *main      = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];
    return resources;
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
