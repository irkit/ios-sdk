//
//  IRSignalTableViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRKit.h"
#import "IRSignalTableViewController.h"
#import "IRSignalLoadingCell.h"
#import "IRSignalCell.h"

@interface IRSignalTableViewController ()

@property (nonatomic) UITableView* tableView;
@property (nonatomic) IRSignals* signals;

@end

@implementation IRSignalTableViewController

- (void)loadView {
    LOG_CURRENT_METHOD;

    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];

    // tableview
    CGRect bounds = view.bounds;
    _tableView = [[UITableView alloc] initWithFrame:bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [view addSubview: _tableView];

    self.view = view;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
    self.title = @"IRKit Signals";
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

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate signalTableViewController:self
                           didFinishWithInfo:@{
                  IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    switch (indexPath.section) {
    case 0:
    {
        if (indexPath.row >= [_signals countOfSignals]) {
            return 44.;
        }
        return [IRSignalCell height];
    }
    break;
    }
    return 0.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row >= [_signals countOfSignals]) {
                // TODO pressed "waiting for signal..."
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LOG_CURRENT_METHOD;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    switch (section) {
        case 0:
        {
            return [_signals countOfSignals] + 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;

    UITableViewCell *cell;

    switch (indexPath.section) {
    case 0:
        {
            if (indexPath.row >= [_signals countOfSignals]) {
                // last line is always "waiting for signal..."
                cell = [tableView dequeueReusableCellWithIdentifier:@"IRSignalLoadingCell"];
                if (cell == nil) {
                    cell = [[IRSignalLoadingCell alloc] initWithReuseIdentifier:@"IRSignalLoadingCell"];
                }
                break;
            }
            cell = [_signals tableView:_tableView
                 cellForRowAtIndexPath:indexPath];
            break;
        }
    }
    return cell;
}

@end
