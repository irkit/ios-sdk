//
//  IRProgressView.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/03/16.
//
//

#import <UIKit/UIKit.h>

@interface IRProgressView : UIView

@property (nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic) IBOutlet UIImageView *checkmarkImageView;
@property (nonatomic) IBOutlet UIImageView *circleBackgroundImageView;

+ (instancetype)showHUDAddedTo:(UIView*)view;
+ (BOOL)hideHUDForView:(UIView*)view afterDelay:(NSTimeInterval)delay;

@end
