//
//  IRReceiveViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRReceiveViewController.h"

@interface IRReceiveViewController ()

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation IRReceiveViewController

- (void)loadView {
    LOG_CURRENT_METHOD;
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    // navbar
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UINavigationItem *title = [[UINavigationItem alloc] initWithTitle:@"Title"];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                    target:self
                                                    action:@selector(cancelButtonPressed:)];
    title.leftBarButtonItem = cancel;
    [navBar pushNavigationItem:title animated:YES];
    [view addSubview:navBar];
    
    // tableview
    CGRect bounds = view.bounds;
    bounds.origin.y = 44;
    bounds.size.height -= 44;
    UITableView *tableView = [[UITableView alloc] initWithFrame:bounds];
    tableView.autoresizingMask =
    UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview: tableView];

    self.tableView = tableView;
    self.view = view;
}

- (void)initialize {
    LOG_CURRENT_METHOD;
    self.delegate = nil;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
    
    [self connect];
}

#pragma mark - 
#pragma - UI events

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self dismissViewControllerAnimated:YES completion:^{
        LOG(@"dismissed");
    }];
}

#pragma - BTLE

- (void)connect {
    LOG_CURRENT_METHOD;
    
    [[IRKit sharedInstance] startScan];
}

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
