//
//  MMViewController.m
//  Minimal
//
//  Created by Masakazu Ohtsuka on 2013/08/06.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "MMViewController.h"

@interface MMViewController ()

@end

@implementation MMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadSignals];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSignals {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSData *data;

    data = [d objectForKey:@"signal1"];
    _signal1 = (IRSignal*)[NSKeyedUnarchiver unarchiveObjectWithData:data];

    data = [d objectForKey:@"signal2"];
    _signal2 = (IRSignal*)[NSKeyedUnarchiver unarchiveObjectWithData:data];

    data = [d objectForKey:@"signal3"];
    _signal3 = (IRSignal*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)saveSignals {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

    if (_signal1) {
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_signal1];
        [d setObject:data
              forKey:@"signal1"];
    }

    if (_signal2) {
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_signal2];
        [d setObject:data
              forKey:@"signal2"];
    }

    if (_signal3) {
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_signal3];
        [d setObject:data
              forKey:@"signal3"];
    }
}

#pragma mark - UI

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    if (! [IRKit sharedInstance].numberOfAuthorizedPeripherals) {
        // TODO
    }
}

- (IBAction)button1Touched:(id)sender {
    LOG_CURRENT_METHOD;
}

- (IBAction)button2Touched:(id)sender {
    LOG_CURRENT_METHOD;
}

- (IBAction)button3Touched:(id)sender {
    LOG_CURRENT_METHOD;
}

@end
