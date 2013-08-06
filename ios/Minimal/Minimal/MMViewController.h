//
//  MMViewController.h
//  Minimal
//
//  Created by Masakazu Ohtsuka on 2013/08/06.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IRKit/IRKit.h>

@interface MMViewController : UIViewController<IRNewPeripheralViewControllerDelegate, IRNewSignalViewControllerDelegate>

@property (nonatomic) NSMutableArray *signals; // of IRSignal

@property (nonatomic) IRPeripheral *peripheral;

@end
