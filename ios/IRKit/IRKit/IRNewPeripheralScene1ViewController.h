//
//  IRNewPeripheralScene1ViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IRNewPeripheralScene1ViewControllerDelegate;

@interface IRNewPeripheralScene1ViewController : UIViewController

@property (nonatomic, assign) id<IRNewPeripheralScene1ViewControllerDelegate> delegate;

@end

@protocol IRNewPeripheralScene1ViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)scene1ViewController:(IRNewPeripheralScene1ViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
