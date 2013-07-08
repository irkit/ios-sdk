//
//  IRSignalTableViewController.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// pre definition for delegate
@protocol IRSignalTableViewControllerDelegate;

@interface IRSignalTableViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) id<IRSignalTableViewControllerDelegate> delegate;

@end

@protocol IRSignalTableViewControllerDelegate <NSObject>

@required
- (void)signalTableViewController:(IRSignalTableViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
