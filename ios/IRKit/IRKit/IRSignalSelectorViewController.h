//
//  IRSignalSelectorViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRKit.h"

#define IRSignalSelectorViewControllerResult          @"result"
#define IRSignalSelectorViewControllerResultCancelled @"cancelled"
#define IRSignalSelectorViewControllerResultNew       @"new"
#define IRSignalSelectorViewControllerSignal          @"signal"

// pre definition for delegate
@protocol IRSignalSelectorViewControllerDelegate;

@interface IRSignalSelectorViewController : UIViewController<UINavigationControllerDelegate>

@property (nonatomic, assign) id<IRSignalSelectorViewControllerDelegate> delegate;

- (void)signalSelected:(id)sender;

@end

@protocol IRSignalSelectorViewControllerDelegate <NSObject>

@required

// Your implementation of this method should dismiss view controller.
- (void)signalSelectorViewController:(IRSignalSelectorViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
