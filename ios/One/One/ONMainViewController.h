//
//  ONMainViewController.h
//  One
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <IRKit/IRKit.h>
#import "ONImagePickerViewController.h"

@interface ONMainViewController : UITableViewController <IRNewPeripheralViewControllerDelegate,
    IRNewSignalViewControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    IRAnimatingControllerDelegate,
    ONImagePickerViewControllerDelegate>

@property (nonatomic) IRSignals *signals;

@end
