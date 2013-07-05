//
//  IRSignalSelectorViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSignalSelectorViewController.h"

@interface IRSignalSelectorViewController ()

@property (nonatomic) UINavigationController *navController;
@property (nonatomic) id observer;
@property (nonatomic) BOOL isShowingNewViewController;
@property (nonatomic) IRSignal *selectedSignal;

@end

@implementation IRSignalSelectorViewController

- (void)loadView {
    LOG_CURRENT_METHOD;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc] initWithFrame:bounds];

    UIViewController *c;
    if ([IRKit sharedInstance].numberOfSignals==0) {
        if ([IRKit sharedInstance].numberOfPeripherals==0) {
            c = [[IRNewPeripheralViewController alloc] init];
            ((IRNewPeripheralViewController*)c).delegate = self;
            _isShowingNewViewController = NO;
        }
        else {
            // show waiting for signal view
            c = [[IRNewSignalViewController alloc] init];
            ((IRNewSignalViewController*)c).delegate = self;
            _isShowingNewViewController = YES;
        }
    }
    else {
        // show tableview of signals, + new signal button
        c = [[IRSignalTableViewController alloc] init];
        ((IRSignalTableViewController*)c).delegate = self;
        _isShowingNewViewController = NO;
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
    
    if (_isShowingNewViewController) {
        [[NSNotificationCenter defaultCenter] removeObserver: _observer]; // avoid duplicate
        _observer = [[NSNotificationCenter defaultCenter]
                     addObserverForName:IRKitDidReceiveSignalNotification
                                 object:nil
                                  queue:[NSOperationQueue mainQueue]
                             usingBlock:^(NSNotification *note) {
                        LOG( @"new signal received");
                         
                        IRSignalNameEditViewController *c = [[IRSignalNameEditViewController alloc] init];
                        c.delegate = self;
                        _isShowingNewViewController = NO;
                        [_navController pushViewController:c
                                                  animated:YES];
                     }];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: _observer];
}

- (void) viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:animated];
}

- (void) dealloc {
    LOG_CURRENT_METHOD;
}

#pragma mark - UI events

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate signalSelectorViewController:self didFinishWithInfo:@{
        IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

- (void)signalSelected:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate signalSelectorViewController:self didFinishWithInfo:@{
        IRViewControllerResultType: IRViewControllerResultTypeDone,
        IRViewControllerResultSignal:
            [[IRKit sharedInstance].signals objectAtIndex:0]
     }];
}

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRNewPeripheralViewController *)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    
    if (info[IRViewControllerResultType] == IRViewControllerResultTypeCancelled) {
        [self.delegate signalSelectorViewController:self
                                  didFinishWithInfo:@{
                         IRViewControllerResultType: IRViewControllerResultTypeCancelled
         }];
        return;
    }
    // success
    IRNewSignalViewController *c = [[IRNewSignalViewController alloc] init];
    ((IRNewSignalViewController*)c).delegate = self;
    _isShowingNewViewController = YES;
    [self.navController pushViewController:c animated:YES];
}

#pragma mark - IRNewSignalViewControllerDelegate

- (void)newSignalViewController:(IRNewSignalViewController *)viewController
              didFinishWithInfo:(NSDictionary *)info {
    LOG_CURRENT_METHOD;
    
    if ([info[IRViewControllerResultType] isEqualToString:IRViewControllerResultTypeCancelled]) {
        if ([IRKit sharedInstance].signals.countOfSignals==0) {
            [self.delegate signalSelectorViewController:self
                                      didFinishWithInfo:@{
                   IRViewControllerResultType: IRViewControllerResultTypeCancelled
             }];
        }
        else {
            // TODO show signal table view
            // c = [[IRSignalTableViewController alloc] init];
        }
    }
    else {
        // received new signal
        
        self.selectedSignal = [[IRKit sharedInstance].signals objectAtIndex:0];
        IRSignalNameEditViewController *c = [[IRSignalNameEditViewController alloc] init];
        c.delegate = self;
        [_navController pushViewController:c animated:YES];
    }
}

#pragma mark - IRSignalNameEditViewControllerDelegate

- (void)signalNameEditViewController:(IRSignalNameEditViewController *)viewController
                   didFinishWithInfo:(NSDictionary*)info;
{
    LOG_CURRENT_METHOD;
    
    if ([info[IRViewControllerResultType] isEqualToString:IRViewControllerResultTypeCancelled]) {
        // TODO show signal table view
        // c = [[IRSignalTableViewController alloc] init];
    }
    else {
        // received new signal, and set a name for it
        
        NSString *signalName = info[IRViewControllerResultText];
        _selectedSignal.name = signalName;
        [[IRKit sharedInstance] save];

        [self.delegate signalSelectorViewController:self
                                  didFinishWithInfo:@{
                IRViewControllerResultType: IRViewControllerResultTypeDone,
                IRViewControllerResultSignal: _selectedSignal
         }];
    }
}

#pragma mark - IRSignalTableViewControllerDelegate

- (void)signalTableViewController:(IRSignalTableViewController *)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;

    if ([info[IRViewControllerResultType] isEqualToString:IRViewControllerResultTypeCancelled]) {
        [self.delegate signalSelectorViewController:self
                                  didFinishWithInfo:@{
                         IRViewControllerResultType: IRViewControllerResultTypeCancelled
         }];
    }
    else {
        // received new signal or selected one
        [self.delegate signalSelectorViewController:self
                                  didFinishWithInfo:@{
                         IRViewControllerResultType: IRViewControllerResultTypeDone,
                       IRViewControllerResultSignal: info[IRViewControllerResultSignal]
         }];
    }
}



@end
