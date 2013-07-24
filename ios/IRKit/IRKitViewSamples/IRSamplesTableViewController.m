//
//  IRSamplesTableViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/07/25.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRSamplesTableViewController.h"
#import "IRNewPeripheralScene1ViewController.h"
#import "IRNewPeripheralScene2ViewController.h"
#import "IRNewPeripheralScene3ViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IRNewPeripheralScene1ViewControllerDelegate

- (void)scene1ViewController:(IRNewPeripheralScene1ViewController *)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IRNewPeripheralScene2ViewControllerDelegate

- (void)scene2ViewController:(IRNewPeripheralScene2ViewController *)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IRNewPeripheralScene3ViewControllerDelegate

- (void)scene3ViewController:(IRNewPeripheralScene3ViewController *)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    switch (indexPath.row) {
        case 0:
        {
            IRNewPeripheralScene1ViewController *c = [[IRNewPeripheralScene1ViewController alloc] init];
            c.delegate = self;

            [self.navigationController pushViewController:c animated:YES];
        }
            break;
        case 1:
        {
            IRNewPeripheralScene2ViewController *c = [[IRNewPeripheralScene2ViewController alloc] init];
            c.delegate = self;

            [self.navigationController pushViewController:c animated:YES];
        }
            break;
        case 2:
        default:
        {
            IRNewPeripheralScene3ViewController *c = [[IRNewPeripheralScene3ViewController alloc] init];
            c.delegate = self;

            [self.navigationController pushViewController:c animated:YES];
        }
            break;
    }
}

@end
