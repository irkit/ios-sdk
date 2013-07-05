//
//  IRNewPeripheralScene2ViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRNewPeripheralScene2ViewController.h"
#import "IRConst.h"

@interface IRNewPeripheralScene2ViewController ()

@property (nonatomic) UILabel *label;

@end

@implementation IRNewPeripheralScene2ViewController

- (void)loadView {
    LOG_CURRENT_METHOD;

    CGRect frame = [[UIScreen mainScreen] bounds];
    LOG(@"frame: %@", NSStringFromCGRect(frame));
    UIView *view = [[UIView alloc] initWithFrame:frame];

    // image
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"IRKitResources.bundle/scene2.png"]];
    imageView.frame = frame;
    [view addSubview: imageView];

    // label
    _label = [[UILabel alloc] init];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.opaque        = NO;
    _label.textColor       = [UIColor whiteColor];
    _label.backgroundColor = [UIColor clearColor];
    _label.adjustsFontSizeToFitWidth = YES;
    frame.origin.x = 0;
    frame.origin.y = frame.size.height / 2 - 50;
    frame.size.height = 100;
    LOG(@"label.frame: %@", NSStringFromCGRect(frame));
    _label.frame = frame;
    [view addSubview:_label];

    self.view = view;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    _label.text = @"IRKitデバイスのボタンを押してください";
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];

    self.title = @"Scene 2";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                              target:self
                              action:@selector(cancelButtonPressed:)];
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

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate scene2ViewController:self
                      didFinishWithInfo:@{
             IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

@end
