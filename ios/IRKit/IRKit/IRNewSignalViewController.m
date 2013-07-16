//
//  IRNewSignalViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRNewSignalViewController.h"
#import "IRSignal.h"
#import "IRConst.h"

@interface IRNewSignalViewController ()

@property (nonatomic) UINavigationController *navController;

@end

@implementation IRNewSignalViewController

- (void)loadView {
    LOG_CURRENT_METHOD;
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    
    IRNewSignalScene1ViewController *first = [[IRNewSignalScene1ViewController alloc] init];
    first.delegate = self;
    
    _navController = [[UINavigationController alloc] initWithRootViewController:first];
    [view addSubview:_navController.view];
    
    self.view = view;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
    
    __weak IRNewSignalViewController *_self = self;
    [[NSNotificationCenter defaultCenter]
        addObserverForName:IRKitDidReceiveSignalNotification
                    object:nil
                     queue:nil
                usingBlock:^(NSNotification *note) {
                    IRSignal* signal = note.userInfo[IRKitSignalUserInfoKey];
                    if ([_delegate respondsToSelector:@selector(newSignalViewController:didFinishWithInfo:)]) {
                        [_delegate performSelector:@selector(newSignalViewController:didFinishWithInfo:)
                                        withObject:_self
                                        withObject:@{
                        IRViewControllerResultType: IRViewControllerResultTypeDone,
                      IRViewControllerResultSignal: signal
                         }];
                    }
                }];
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];

    // hack http://stackoverflow.com/questions/5183834/uinavigationcontroller-within-viewcontroller-gap-at-top-of-view
    // prevent showing the weird 20px empty zone on top of navigationbar
    // when presented in caller's viewDidLoad
    [_navController setNavigationBarHidden:YES];
    [_navController setNavigationBarHidden:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IRNewSignalScene1ViewControllerDelegate

- (void)scene1ViewController:(IRNewSignalScene1ViewController *)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    
    if ([info[IRViewControllerResultType] isEqualToString:IRViewControllerResultTypeCancelled]) {
        [self.delegate newSignalViewController:self
                             didFinishWithInfo:@{
                        IRViewControllerResultType: IRViewControllerResultTypeCancelled
         }];
    }
    // shouldnt happen
}

@end
