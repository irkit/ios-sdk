//
//  IRNewPeripheralViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRKit.h"

#define IRNewPeripheralViewControllerResult          @"result"
#define IRNewPeripheralViewControllerResultCancelled @"cancelled"
#define IRNewPeripheralViewControllerResultNew       @"new"
#define IRNewPeripheralViewControllerPeripheral      @"peripheral"

// pre definition for delegate
@protocol IRNewPeripheralViewControllerDelegate;

@interface IRNewPeripheralViewController : UIViewController<UINavigationControllerDelegate>

@property (nonatomic, assign) id<IRNewPeripheralViewControllerDelegate> delegate;

- (void)doneButtonPressed:(id)sender;

@end

@protocol IRNewPeripheralViewControllerDelegate <NSObject>

@required

// Your implementation of this method should dismiss view controller.
- (void)newPeripheralViewController:(IRNewPeripheralViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
