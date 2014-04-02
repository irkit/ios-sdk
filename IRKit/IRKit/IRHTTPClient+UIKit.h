//
//  IRHTTPClient+UIKit.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/04/02.
//
//

#import "IRHTTPClient.h"
#import <UIKit/UIKit.h>

@interface IRHTTPClient (UIKit)

+ (void)loadImage:(NSString *)url completionHandler:(void (^) (NSHTTPURLResponse * response, UIImage * image, NSError * error))handler;

@end
