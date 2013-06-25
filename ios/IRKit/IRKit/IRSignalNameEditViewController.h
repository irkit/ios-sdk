//
//  IRSignalNameEditViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// pre definition for delegate
@protocol IRSignalNameEditViewControllerDelegate;

@interface IRSignalNameEditViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) id<IRSignalNameEditViewControllerDelegate> delegate;

@end

@protocol IRSignalNameEditViewControllerDelegate <NSObject>

@required

// Your implementation of this method should hide this view controller.
- (void)signalNameEditViewController:(IRSignalNameEditViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
