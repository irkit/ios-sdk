//
//  IRNewPeripheralScene1ViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRNewPeripheralScene1ViewController.h"
#import "IRNewPeripheralScene2ViewController.h"
#import "IRPeripheralNameEditViewController.h"
#import "IRConst.h"
#import "IRPeripherals.h"
#import "IRPeripheral.h"
#import "IRViewCustomizer.h"
#import "IRKit.h"

@interface IRNewPeripheralScene1ViewController ()

@property (nonatomic) id observer;

@end

@implementation IRNewPeripheralScene1ViewController

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

    self.title = @"Searching for IRKit...";
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

    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:IRKitDidConnectPeripheralNotification
                                                                  object:nil
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *note) {
                                                                  LOG( @"new irkit connected");
                                                                  [self didConnectPeripheral: note.object];
                                                              }];

    IRPeripherals *peripherals = [IRKit sharedInstance].peripherals;
    for (IRPeripheral *peripheral in peripherals.peripherals) {
        if (peripheral.isReady && ! peripheral.authorized) {
            // user might have already connected their peripheral
            [self didConnectPeripheral:peripheral];
            return;
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}

- (void) didConnectPeripheral: (IRPeripheral*)peripheral {
    LOG_CURRENT_METHOD;

    [[NSNotificationCenter defaultCenter] removeObserver:_observer];

    NSBundle *main = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];

    if (peripheral.authorized) {
        LOG( @"already authorized" );
        // skip to step3 if peripheral
        // remembers me
        IRPeripheralNameEditViewController *c = [[IRPeripheralNameEditViewController alloc] initWithNibName:@"IRPeripheralNameEditViewController"
                                                                                                       bundle:resources];
        c.delegate = self.delegate;
        c.peripheral = peripheral;
        [self.navigationController pushViewController:c
                                             animated:YES];
        return;
    }
    IRNewPeripheralScene2ViewController *c = [[IRNewPeripheralScene2ViewController alloc] initWithNibName:@"IRNewPeripheralScene2ViewController"
                                                                                                       bundle:resources];
    c.peripheral = peripheral;
    c.delegate = self.delegate;
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
    [self.delegate scene1ViewController:self
                      didFinishWithInfo:@{
           IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

@end
