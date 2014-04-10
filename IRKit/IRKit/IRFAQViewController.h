//
//  IRFAQViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/04/10.
//
//

#import <UIKit/UIKit.h>

@protocol IRFAQViewControllerDelegate;

@interface IRFAQViewController : UIViewController

@property (weak, nonatomic) id<IRFAQViewControllerDelegate> delegate;

@end

@protocol IRFAQViewControllerDelegate <NSObject>

- (void)faqViewControllerDidFinish:(IRFAQViewController*)controller;

@end