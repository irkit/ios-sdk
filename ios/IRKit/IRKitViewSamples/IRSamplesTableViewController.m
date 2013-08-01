//
//  IRSamplesTableViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/07/25.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSamplesTableViewController.h"
#import "IRconst.h"
#import "IRNewPeripheralScene1ViewController.h"
#import "IRNewPeripheralScene2ViewController.h"
#import "IRPeripheralNameEditViewController.h"
#import "IRNewSignalScene1ViewController.h"
#import "IRSignalNameEditViewController.h"
#import "IRWebViewController.h"
#import "IRSignal.h"
#import "IRSignalCell.h"
#import "IRPeripheralCell.h"

@interface IRSamplesTableViewController ()

@end

@implementation IRSamplesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    NSBundle *main = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];
    [self.tableView registerNib:[UINib nibWithNibName:@"IRSignalCell" bundle:resources]
         forCellReuseIdentifier:IRKitCellIdentifierSignal];
    [self.tableView registerNib:[UINib nibWithNibName:@"IRPeripheralCell" bundle:resources]
         forCellReuseIdentifier:IRKitCellIdentifierPeripheral];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IRNewPeripheralScene1ViewControllerDelegate
#pragma mark - IRNewSignalScene1ViewControllerDelegate

//  TODO merge all callbacks into a single IRViewController:didFinishWithInfo: message?
- (void)scene1ViewController:(id)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IRNewPeripheralScene2ViewControllerDelegate
#pragma mark - IRSignalNameEditViewControllerDelegate

- (void)scene2ViewController:(id)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IRPeripheralNameEditViewControllerDelegate

- (void)scene3ViewController:(IRPeripheralNameEditViewController *)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return [tableView dequeueReusableCellWithIdentifier:@"IRNewPeripheralScene1"];
        case 1:
            return [tableView dequeueReusableCellWithIdentifier:@"IRNewPeripheralScene2"];
        case 2:
            return [tableView dequeueReusableCellWithIdentifier:@"IRPeripheralNameEdit"];
        case 3:
            return [tableView dequeueReusableCellWithIdentifier:@"IRNewSignalScene1"];
        case 4:
            return [tableView dequeueReusableCellWithIdentifier:@"IRSignalNameEdit"];
        case 5:
            return [tableView dequeueReusableCellWithIdentifier:@"IRWeb"];
        case 6:
        {
            IRSignalCell *cell = [tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierSignal];

            unsigned short data[10] = { 100,100,100,100,100,100,100,100,100,100 };
            NSData *irdata = [NSData dataWithBytes:data length:10];
            IRSignal *signal = [[IRSignal alloc] initWithData: irdata];

            [cell inflateFromSignal:signal];
            return cell;
        }
        case 7:
        {
            IRPeripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierPeripheral];
            IRPeripheral *peripheral = [[IRPeripheral alloc] init];
            peripheral.customizedName = @"my IRKit";
            cell.peripheral = peripheral;
            return cell;
        }
        default:
            return [tableView dequeueReusableCellWithIdentifier:@"IRNewSignalScene1"];
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 6:
            return [IRSignalCell height];
        case 7:
            return [IRPeripheralCell height];

        default:
            return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSBundle *main = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources" ofType:@"bundle"]];
    switch (indexPath.row) {
        case 0:
        {
            IRNewPeripheralScene1ViewController *c = [[IRNewPeripheralScene1ViewController alloc] initWithNibName:@"IRNewPeripheralScene1ViewController"
                                                                                                           bundle:resources];
            c.delegate = self;

            [self.navigationController pushViewController:c animated:YES];
        }
            break;
        case 1:
        {
            IRNewPeripheralScene2ViewController *c = [[IRNewPeripheralScene2ViewController alloc] initWithNibName:@"IRNewPeripheralScene2ViewController"
                                                                                                           bundle:resources];
            c.delegate = self;

            [self.navigationController pushViewController:c animated:YES];
        }
            break;
        case 2:
        {
            IRPeripheralNameEditViewController *c = [[IRPeripheralNameEditViewController alloc] initWithNibName:@"IRPeripheralNameEditViewController"
                                                                                                           bundle:resources];
            c.delegate = self;
            IRPeripheral *peripheral = [[IRPeripheral alloc] init];
            c.peripheral = peripheral;

            [self.navigationController pushViewController:c animated:YES];
        }
            break;
        case 3:
        {
            IRNewSignalScene1ViewController *c = [[IRNewSignalScene1ViewController alloc] initWithNibName:@"IRNewSignalScene1ViewController"
                                                                                                   bundle:resources];
            c.delegate = self;

            [self.navigationController pushViewController:c animated:YES];
        }
            break;
        case 4:
        {
            IRSignalNameEditViewController *c = [[IRSignalNameEditViewController alloc] initWithNibName:@"IRSignalNameEditViewController"
                                                                                                   bundle:resources];
            c.delegate = self;
            unsigned short data[10] = { 100,100,100,100,100,100,100,100,100,100 };
            NSData *irdata = [NSData dataWithBytes:data length:10];
            IRSignal *signal = [[IRSignal alloc] initWithData: irdata];
            c.signal = signal;

            [self.navigationController pushViewController:c animated:YES];
        }
            break;
        case 5:
        {
            IRWebViewController *c = [[IRWebViewController alloc] init];
            c.url = @"http://github.com/irkit/";
            c.title = @"github.com/irkit";
            [self.navigationController pushViewController:c animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
