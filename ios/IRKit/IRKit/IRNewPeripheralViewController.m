//
//  IRNewPeripheralViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRNewPeripheralViewController.h"
#import "IRNewPeripheralScene1ViewController.h"

@interface IRNewPeripheralViewController ()

@property (nonatomic) UINavigationController *navController;

@end

NSString *NSStringFromIRNewPeripheralResult(IRNewPeripheralResult result)
{
    NSString *ret;
    switch (result) {
        case IRNewPeripheralResultCancelled:
            ret = @"Cancelled";
            break;
        case IRNewPeripheralResultNew:
            ret = @"New";
            break;
        default:
            LOG( @"unexpected result: %d", result );
            ret = @"*UNEXPECTED RESULT*";
    }
    return ret;
}

@implementation IRNewPeripheralViewController

- (void)loadView {
    LOG_CURRENT_METHOD;
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc] initWithFrame:bounds];

    UIViewController *first = [[IRNewPeripheralScene1ViewController alloc]init];
    _navController = [[UINavigationController alloc] initWithRootViewController:first];
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

#pragma mark -
#pragma mark UI events

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate newPeripheralViewController:self
                           didFinishWithResult:IRNewPeripheralResultCancelled];
}

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
