//
//  IRNewPeripheralViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRKit.h"

typedef NS_ENUM( NSUInteger, IRNewPeripheralResult ) {
    IRNewPeripheralResultCancelled = 0,
    IRNewPeripheralResultNew       = 1
};
NSString *NSStringFromIRNewPeripheralResult(IRNewPeripheralResult);

// pre definition for delegate
@protocol IRNewPeripheralViewControllerDelegate;

@interface IRNewPeripheralViewController : UIViewController<UINavigationControllerDelegate>

@property (nonatomic, assign) id<IRNewPeripheralViewControllerDelegate> delegate;

@end

@protocol IRNewPeripheralViewControllerDelegate <NSObject>

@required

// Your implementation of this method should dismiss view controller.
- (void)newPeripheralViewController:(IRNewPeripheralViewController *)viewController didFinishWithResult:(IRNewPeripheralResult)result;

@end
