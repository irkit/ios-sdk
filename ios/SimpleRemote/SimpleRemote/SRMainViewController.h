//
//  SRMainViewController.h
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <IRKit/IRKit.h>

@interface SRMainViewController : UITableViewController <IRNewPeripheralViewControllerDelegate,
    IRNewSignalViewControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    IRAnimatingControllerDelegate>

@end
