//
//  SRSettingsViewController.m
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/07/09.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "SRSettingsViewController.h"
#import <BlocksKit/BlocksKit.h>

@interface SRSettingsViewController ()

@end

@implementation SRSettingsViewController

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

- (IBAction)doneButtonTouched:(id)sender {
    LOG_CURRENT_METHOD;
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 LOG(@"dismissed");
                             }];
}

#pragma mark - IRPeripheralNameEditViewControllerDelegate

- (void)peripheralNameEditViewController:(IRPeripheralNameEditViewController *)viewController didFinishWithInfo:(NSDictionary*)info
{
    LOG( @"info: %@", info );
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 LOG(@"dismissed");
                             }];
}

#pragma mark - IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRNewPeripheralViewController *)viewController didFinishWithInfo:(NSDictionary *)info
{
    LOG( @"info: %@", info );
    [self dismissViewControllerAnimated:YES
                             completion:^{
        LOG(@"dismissed");
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [[IRKit sharedInstance].peripherals tableView:self.tableView
                                           numberOfRowsInSection:0] + 1;
        case 1:
            return 3;
        default:
            break;
    }
    return 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            return @"Peripherals";
        case 1:
            return @"Info";
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;

    UITableViewCell *cell;

    switch (indexPath.section) {
        case 0:
            if ([IRKit sharedInstance].numberOfPeripherals <= indexPath.row) {
                // last line is always "+ Add New Peripheral"
                cell = [tableView dequeueReusableCellWithIdentifier:@"NewPeripheralCell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:@"NewPeripheralCell"];
                }
                cell.textLabel.text = @"+ Add New Peripheral";
                break;
            }
            cell = [[IRKit sharedInstance].peripherals tableView:tableView
                                           cellForRowAtIndexPath:indexPath];
            break;
        case 1:
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"cell"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Help";
                    break;
                case 1:
                    cell.textLabel.text = @"Open Source";
                    break;
                case 2:
                    cell.textLabel.text = @"Buy Peripheral";
                    break;
            }
            break;
    }
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
        {
            if ([IRKit sharedInstance].numberOfPeripherals <= indexPath.row) {
                // pressed Add New Peripheral cell
                IRNewPeripheralViewController *c = [[IRNewPeripheralViewController alloc] init];
                c.delegate = (id<IRNewPeripheralViewControllerDelegate>)self;
                [self presentViewController:c
                                   animated:YES
                                 completion:^{
                    LOG( @"presented" );
                }];
                return;
            }
            IRPeripheral *peripheral = [[IRKit sharedInstance].peripherals objectAtIndex: indexPath.row];
            UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:@""];
            [sheet addButtonWithTitle:@"Edit Name" handler:^{
                IRPeripheralNameEditViewController *c = [[IRPeripheralNameEditViewController alloc] init];
                c.peripheral = peripheral;
                c.delegate   = self;
                [self.navigationController pushViewController:c
                                                     animated:YES];
            }];
            [sheet setCancelButtonWithTitle:nil handler:^{
                LOG( @"canceled" );
            }];
            [sheet showInView:self.view];
            break;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    IRWebViewController *c = [[IRWebViewController alloc] init];
                    c.url = @"https://lobi.co/sp/faq/ja";
                    c.title = @"Help";
                    [self.navigationController pushViewController:c
                                                         animated:YES];
                    break;
                }
                case 1:
                {
                    IRWebViewController *c = [[IRWebViewController alloc] init];
                    c.url = @"http://github.com/mash";
                    c.title = @"Opensource";
                    [self.navigationController pushViewController:c
                                                         animated:YES];
                    break;
                }
                case 2:
                {
                    IRWebViewController *c = [[IRWebViewController alloc] init];
                    c.url = @"http://www.amazon.co.jp/";
                    c.title = @"Buy Peripheral";
                    [self.navigationController pushViewController:c
                                                         animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

@end
