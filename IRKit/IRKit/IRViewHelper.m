//
//  IRViewHelper.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/04/01.
//
//

#import "IRViewHelper.h"
#import "IRHelper.h"

@implementation IRViewHelper

+ (void)enumerateSubviewsOfRootView:(UIView *)view usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    block(view, 0, 0);
    for (UIView *subview in view.subviews) {
        [self enumerateSubviewsOfRootView: subview usingBlock: block];
    }
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
    NSBundle *bundle = [IRHelper resources];
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
