//
//  IRPeripheralNameEditViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRPeripheral.h"

@protocol IRPeripheralNameEditViewControllerDelegate;

@interface IRPeripheralNameEditViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) id<IRPeripheralNameEditViewControllerDelegate> delegate;
@property (nonatomic) IRPeripheral *peripheral;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end

@protocol IRPeripheralNameEditViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)scene3ViewController:(IRPeripheralNameEditViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
