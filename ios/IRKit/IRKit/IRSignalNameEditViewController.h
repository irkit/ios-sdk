//
//  IRSignalNameEditViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRSignal.h"

@protocol IRSignalNameEditViewControllerDelegate;

@interface IRSignalNameEditViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) id<IRSignalNameEditViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) IRSignal *signal;

@end

@protocol IRSignalNameEditViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)scene2ViewController:(IRSignalNameEditViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
