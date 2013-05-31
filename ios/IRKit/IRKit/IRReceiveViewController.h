//
//  IRReceiveViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRKit.h"

// pre definition for delegate
@protocol IRReceiveViewDelegate;

@interface IRReceiveViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) id<IRReceiveViewDelegate> delegate;

@end

@protocol IRReceiveViewDelegate <NSObject>

@required
- (void)receiveViewControllerDidFinish:(IRReceiveViewController *)viewController;

@end
