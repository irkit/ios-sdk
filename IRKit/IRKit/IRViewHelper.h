//
//  IRViewHelper.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/04/01.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IRViewHelper : NSObject

+ (void)enumerateSubviewsOfRootView:(UIView *)view usingBlock:(void (^) (id obj, NSUInteger idx, BOOL * stop))block;
+ (UIFont *)fontWithSize:(CGFloat)size;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageInResourceNamed:(NSString *)name;

@end
