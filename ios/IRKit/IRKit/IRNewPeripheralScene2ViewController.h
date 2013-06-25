//
//  IRNewPeripheralScene2ViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IRNewPeripheralScene2ViewControllerDelegate;

@interface IRNewPeripheralScene2ViewController : UIViewController

@property (nonatomic, assign) id<IRNewPeripheralScene2ViewControllerDelegate> delegate;

@end

@protocol IRNewPeripheralScene2ViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)scene2ViewController:(IRNewPeripheralScene2ViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
