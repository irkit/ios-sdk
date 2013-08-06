//
//  IRNewSignalViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRNewSignalScene1ViewController.h"
#import "IRSignalNameEditViewController.h"

// pre definition for delegate
@protocol IRNewSignalViewControllerDelegate;

@interface IRNewSignalViewController : UIViewController<IRNewSignalScene1ViewControllerDelegate,IRSignalNameEditViewControllerDelegate>

@property (nonatomic, assign) id<IRNewSignalViewControllerDelegate> delegate;

@end

@protocol IRNewSignalViewControllerDelegate <NSObject>

@required

// Your implementation of this method should dismiss view controller.
- (void)newSignalViewController:(IRNewSignalViewController *)viewController didFinishWithSignal:(IRSignal*)signal;

@end
