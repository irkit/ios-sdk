//
//  IRSignalSelectorViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignalSelectorViewController.h"
#import "IRNewSignalViewController.h"

@interface IRSignalSelectorViewController ()

@property (nonatomic) UINavigationController *navController;

@end

@implementation IRSignalSelectorViewController

- (void)loadView {
    LOG_CURRENT_METHOD;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc] initWithFrame:bounds];

    UIViewController *c;
    if ([IRKit sharedInstance].signals.count==0) {
        // show waiting for signal view
        c = [[IRNewSignalViewController alloc] init];
    }
    else {
        // show tableview of signals, + new signal button
        // c = [[IRSignalTableViewController alloc] init];
    }
    
    _navController = [[UINavigationController alloc] initWithRootViewController:c];
    _navController.delegate = self;
    [view addSubview:_navController.view];

    self.view = view;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];

    // hack http://stackoverflow.com/questions/5183834/uinavigationcontroller-within-viewcontroller-gap-at-top-of-view
    // prevent showing the weird 20px empty zone on top of navigationbar
    // when presented in caller's viewDidLoad
    [self.navController setNavigationBarHidden:YES];
    [self.navController setNavigationBarHidden:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:animated];
}

- (void) dealloc {
    LOG_CURRENT_METHOD;
}

#pragma mark -
#pragma mark UI events

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate signalSelectorViewController:self didFinishWithInfo:@{
        IRSignalSelectorViewControllerResult: IRSignalSelectorViewControllerResultCancelled
     }];
}

- (void)signalSelected:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate signalSelectorViewController:self didFinishWithInfo:@{
        IRSignalSelectorViewControllerResult: IRSignalSelectorViewControllerResultNew,
        IRSignalSelectorViewControllerSignal:
            [[IRKit sharedInstance].signals objectAtIndex:0]
     }];
}

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
