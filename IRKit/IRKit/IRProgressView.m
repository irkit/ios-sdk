//
//  IRProgressView.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/03/16.
//
//  pretty much copied from MBProgressHUD.m
//
//  MBProgressHUD.m
//  Version 0.8
//  Created by Matej Bukovinski on 2.4.09.
//  MIT License
//


#import "IRProgressView.h"
#import "IRHelper.h"

@interface IRProgressView ()

@property (nonatomic) BOOL removeFromSuperViewOnHide;
@property (nonatomic) CGAffineTransform rotationTransform;
@property (nonatomic) NSDate *showStarted;
@property (nonatomic) BOOL isFinished;

@end

@implementation IRProgressView

- (void)awakeFromNib {
    [super awakeFromNib];

    _rotationTransform    = CGAffineTransformIdentity;
    _indicatorView.hidden = NO;
    [_indicatorView startAnimating];
    _checkmarkImageView.hidden = YES;

    self.alpha = 0.;
}

+ (instancetype)showHUDAddedTo:(UIView *)parent {
    NSArray* nibViews = [[IRHelper resources] loadNibNamed: @"IRProgressView"
                                                     owner: self
                                                   options: nil];
    IRProgressView *hud;
    for (id object in nibViews) {
        if ([object isKindOfClass: [IRProgressView class]]) {
            hud = (IRProgressView *)object;
        }
    }

    hud.frame = parent.bounds;
    [parent addSubview: hud];
    [hud setNeedsDisplay];
    [hud showUsingAnimation];
    return hud;
}

+ (BOOL)hideHUDForView:(UIView *)view afterDelay:(NSTimeInterval)delay {
    IRProgressView *hud = [self HUDForView: view];
    if (hud != nil) {
        hud.removeFromSuperViewOnHide = YES;

        // switch to checkmark, and hide after delay
        [hud.indicatorView stopAnimating];
        hud.indicatorView.hidden      = YES;
        hud.checkmarkImageView.hidden = NO;

        [hud hideUsingAnimationAfterDelay: delay];
        return YES;
    }
    return NO;
}

+ (instancetype)HUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass: self]) {
            return (IRProgressView *)subview;
        }
    }
    return nil;
}

- (void)showUsingAnimation {
    self.transform   = CGAffineTransformConcat(_rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
    self.showStarted = [NSDate date];

    // Fade in
    [UIView beginAnimations: nil context: NULL];
    [UIView setAnimationDuration: 0.30];
    self.alpha     = 1.0f;
    self.transform = _rotationTransform;
    [UIView commitAnimations];
}

- (void)hideUsingAnimationAfterDelay:(NSTimeInterval)delay {
    // Fade out
    if (_showStarted) {
        [UIView beginAnimations: nil context: NULL];
        [UIView setAnimationDelay: delay];
        [UIView setAnimationDuration: 0.30];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(animationFinished:finished:context:)];
        // 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
        // in the done method
        self.transform = CGAffineTransformConcat(_rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));

        self.alpha = 0.02f;
        [UIView commitAnimations];
    }
    else {
        self.alpha = 0.0f;
        [self done];
    }
    self.showStarted = nil;
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
    [self done];
}

- (void)done {
    [NSObject cancelPreviousPerformRequestsWithTarget: self];
    _isFinished = YES;
    self.alpha  = 0.0f;
    if (_removeFromSuperViewOnHide) {
        [self removeFromSuperview];
    }
}

@end
