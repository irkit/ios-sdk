//
//  IRNewSignalScene2ViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRSignal.h"

@protocol IRNewSignalScene2ViewControllerDelegate;

@interface IRNewSignalScene2ViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) id<IRNewSignalScene2ViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) IRSignal *signal;

@end

@protocol IRNewSignalScene2ViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)scene2ViewController:(IRNewSignalScene2ViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
