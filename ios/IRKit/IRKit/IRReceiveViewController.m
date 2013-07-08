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
#import "IRPeripheralCell.h"
#import "IRSignalCell.h"

@interface IRReceiveViewController ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) id peripheralDiscoveredObserver;

@end

@implementation IRReceiveViewController

- (void)loadView {
    LOG_CURRENT_METHOD;
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    // navbar
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UINavigationItem *title = [[UINavigationItem alloc] initWithTitle:@"IRKit Devices & Signals"];
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

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
    
    [[IRKit sharedInstance].peripherals addObserver:self
                                         forKeyPath:@"peripherals"
                                            options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                                            context:NULL];
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];
    
    [[IRKit sharedInstance].peripherals removeObserver:self
                                            forKeyPath:@"peripherals"];
}

#pragma mark - UI events

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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    LOG( @"keyPath: %@", keyPath );

    int changeKind = [change[NSKeyValueChangeKindKey] intValue];
    switch (changeKind) {
        case NSKeyValueChangeInsertion:
        {
            BOOL firstPeripheral = ([IRKit sharedInstance].numberOfPeripherals == 1);

            [self.tableView beginUpdates];
            if (firstPeripheral) {
                // it's our first peripheral
                // let's show the signals section
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else {
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self.tableView endUpdates];
            break;
        }
        case NSKeyValueChangeRemoval:
        {
            // TODO animation
            [self.tableView reloadData];
//            [self.tableView beginUpdates];
//            [self.tableView deleteRowsAtIndexPaths:indexes
//                                  withRowAnimation:UITableViewRowAnimationFade];
//            [self.tableView endUpdates];
            break;
        }
        case NSKeyValueChangeReplacement:
        {
            [self.tableView reloadData];
//            [self.tableView beginUpdates];
//            [self.tableView reloadRowsAtIndexPaths:indexes
//                                  withRowAnimation:UITableViewRowAnimationFade];
//            [self.tableView endUpdates];
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    switch (indexPath.section) {
        case 0:
        {
            return 44;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    return 200;
                default:
                    return 44;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            break;
        }
        case 1:
        {
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LOG_CURRENT_METHOD;
    if ([IRKit sharedInstance].numberOfPeripherals > 0) {
        return 2;
    }
    return 1;
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
            return [IRKit sharedInstance].numberOfSignals + 1;
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
                cell = [[IRPeripheralCell alloc] initWithReuseIdentifier:@"IRPeripheralCell"];
            }
            ((IRPeripheralCell*)cell).peripheral = [[IRKit sharedInstance].peripherals objectAtIndex: indexPath.row];
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
                cell = [[IRSignalCell alloc] initWithReuseIdentifier:@"IRSignalCell"];
            }
            ((IRSignalCell*)cell).signal = [[IRSignal alloc] init];
            return cell;
        }
    }
    return cell;
}

@end
