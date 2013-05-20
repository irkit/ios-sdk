//
//  IRReceiveViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRReceiveViewController.h"
#import "IRPeripheralLoadingCell.h"
#import "IRSignalLoadingCell.h"

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
    UITableView *tableView = [[UITableView alloc] initWithFrame:bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    [view addSubview: tableView];

    self.tableView = tableView;
    self.view = view;
}

- (void)initialize {
    LOG_CURRENT_METHOD;
    _delegate = nil;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
    
}

#pragma mark - 
#pragma - UI events

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self dismissViewControllerAnimated:YES completion:^{
        LOG(@"dismissed");
    }];
}

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LOG_CURRENT_METHOD;
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch(section) {
        case 0:
            return @"Devices";
        case 1:
            return @"Signals";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    switch (section) {
        case 0:
        {
            return [IRKit sharedInstance].numberOfPeripherals + 1;
        }
        case 1:
        {
            return 1;
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
            if ([IRKit sharedInstance].numberOfPeripherals <= indexPath.row) {
                // last line is always "loading..."
                cell = [tableView dequeueReusableCellWithIdentifier:@"IRPeripheralLoadingCell"];
                if (cell == nil) {
                    cell = [[IRPeripheralLoadingCell alloc] initWithReuseIdentifier:@"IRPeripheralLoadingCell"];
                }
                return cell;
            }
            // otherwise show peripheral info
            cell = [tableView dequeueReusableCellWithIdentifier:@"IRPeripheralCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IRPeripheralCell"];
            }
            return cell;
        }
    case 1:
        {
            if ([IRKit sharedInstance].numberOfPeripherals == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"IRSignalNoPeripheralsCell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IRSignalNoPeripheralsCell"];
                    cell.textLabel.text = @"no devices found yet";
                }
                return cell;
            }
            if ([IRKit sharedInstance].numberOfSignals <= indexPath.row) {
                // last line is always "waiting for signal..."
                cell = [tableView dequeueReusableCellWithIdentifier:@"IRSignalLoadingCell"];
                if (cell == nil) {
                    cell = [[IRSignalLoadingCell alloc] initWithReuseIdentifier:@"IRSignalLoadingCell"];
                }
                return cell;
            }
            // otherwise show signal info
            cell = [tableView dequeueReusableCellWithIdentifier:@"IRSignalCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IRSignalCell"];
            }
            return cell;
        }
    }
    return cell;
}

@end
