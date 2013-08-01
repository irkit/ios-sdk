//
//  IRNewPeripheralScene2ViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRNewPeripheralScene2ViewController.h"
#import "IRPeripheralNameEditViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"

@interface IRNewPeripheralScene2ViewController ()

@property (nonatomic) id observer;

@end

@implementation IRNewPeripheralScene2ViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title = @"Waiting for Pairing...";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelButtonPressed:)];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:animated];

    if (_peripheral.authorized) {
        [self didAuthorize];
        return;
    }
    // TODO what if authorized here? synchronize?
    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:IRKitDidAuthorizePeripheralNotification
                                                                  object:nil
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *note) {
                                                                  LOG( @"irkit authorized");
                                                                  [self didAuthorize];
                                                              }];
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}

- (void) didAuthorize {
    LOG_CURRENT_METHOD;

    [[NSNotificationCenter defaultCenter] removeObserver:_observer];

    NSBundle *main = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];
    IRPeripheralNameEditViewController *c = [[IRPeripheralNameEditViewController alloc] initWithNibName:@"IRPeripheralNameEditViewController"
                                                                                                   bundle:resources];
    c.delegate = self.delegate;
    c.peripheral = _peripheral;
    [self.navigationController pushViewController:c
                                         animated:YES];
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate scene2ViewController:self
                      didFinishWithInfo:@{
             IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

@end
