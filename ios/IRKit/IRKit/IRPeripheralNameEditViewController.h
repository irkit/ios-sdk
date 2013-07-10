//
//  IRPeripheralNameEditViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRPeripheral.h"

// pre definition for delegate
@protocol IRPeripheralNameEditViewControllerDelegate;

@interface IRPeripheralNameEditViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) id<IRPeripheralNameEditViewControllerDelegate> delegate;
@property (nonatomic) IRPeripheral *peripheral;

@end

@protocol IRPeripheralNameEditViewControllerDelegate <NSObject>

@required

// Your implementation of this method should hide this view controller.
- (void)peripheralNameEditViewController:(IRPeripheralNameEditViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
