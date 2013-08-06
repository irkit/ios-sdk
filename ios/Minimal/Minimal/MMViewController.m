//
//  MMViewController.m
//  Minimal
//
//  Created by Masakazu Ohtsuka on 2013/08/06.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "MMViewController.h"

@interface MMViewController ()

@property (nonatomic) NSUInteger signalIndex;

@end

@implementation MMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _signals = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], nil];

    // buttons has tags 1,2,3 respectively
    [(UIButton*)[self.view viewWithTag:1] setTitle: @"Unset" forState:UIControlStateNormal];
    [(UIButton*)[self.view viewWithTag:2] setTitle: @"Unset" forState:UIControlStateNormal];
    [(UIButton*)[self.view viewWithTag:3] setTitle: @"Unset" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    if (! _peripheral) {
        IRNewPeripheralViewController *vc = [[IRNewPeripheralViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             LOG(@"presented");
                         }];
    }
}

- (IBAction)buttonTouched:(id)sender {
    LOG_CURRENT_METHOD;

    _signalIndex = ((UIView*)sender).tag - 1;
    
    IRSignal *signal = _signals[ _signalIndex ];
    if (! _peripheral) {
        IRNewPeripheralViewController *vc = [[IRNewPeripheralViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             LOG(@"presented");
                         }];
    }
    else if ([signal isEqual:[NSNull null]]) {
        IRNewSignalViewController *vc = [[IRNewSignalViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             LOG(@"presented");
                         }];
    }
    else {
        [signal sendWithCompletion:^(NSError *error) {
            LOG(@"sent error: %@", error);
        }];
    }
}

#pragma mark - IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRNewPeripheralViewController *)viewController
            didFinishWithPeripheral:(IRPeripheral *)peripheral {
    LOG( @"peripheral: %@", peripheral );

    if (peripheral) {
        _peripheral = peripheral;
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 LOG(@"dismissed");
                             }];
}

#pragma mark - IRNewSignalViewControllerDelegate

- (void)newSignalViewController:(IRNewSignalViewController *)viewController
            didFinishWithSignal:(IRSignal *)signal {
    LOG( @"signal: %@", signal );

    if (signal) {
        [_signals replaceObjectAtIndex:_signalIndex
                            withObject:signal];
        UIButton *button = (UIButton*)[self.view viewWithTag:(_signalIndex + 1)];
        [button setTitle:signal.name
                forState:UIControlStateNormal];
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 LOG(@"dismissed");
                             }];
}

@end
