//
//  IRNewPeripheralScene3ViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IRNewPeripheralScene3ViewControllerDelegate;

@interface IRNewPeripheralScene3ViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) id<IRNewPeripheralScene3ViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@protocol IRNewPeripheralScene3ViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)scene3ViewController:(IRNewPeripheralScene3ViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end