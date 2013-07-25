//
//  SRSettingsViewController.h
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/07/09.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IRKit/IRKit.h>

@interface SRSettingsViewController : UITableViewController<IRNewPeripheralViewControllerDelegate,
    IRPeripheralNameEditViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *versionButton;

@end
