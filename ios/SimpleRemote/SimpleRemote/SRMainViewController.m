//
//  SRMainViewController.m
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "SRMainViewController.h"

@interface SRMainViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBarButtonItem;

@end

@implementation SRMainViewController

- (void)viewDidLoad
{
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:YES];

    if ([IRKit sharedInstance].numberOfPeripherals == 0) {
        IRNewPeripheralViewController* c = [[IRNewPeripheralViewController alloc] init];
        c.delegate = (id<IRNewPeripheralViewControllerDelegate>)self;
        [self presentViewController:c animated:YES completion:^{
            LOG( @"presented" );
        }];
    }
}

- (IBAction)addBarButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    
    IRNewPeripheralViewController* c = [[IRNewPeripheralViewController alloc] init];
    c.delegate = (id<IRNewPeripheralViewControllerDelegate>)self;
    [self presentViewController:c animated:YES completion:^{
        LOG( @"presented" );
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRReceiveViewController *)viewController
                  didFinishWithInfo:(NSDictionary*)info {
    LOG( @"info: %@", info );
 
    [self dismissViewControllerAnimated:YES completion:^{
        LOG(@"dismissed");
    }];
}

#pragma mark -
#pragma mark IRSignalSelectorViewControllerDelegate

- (void)signalSelectorViewController:(IRSignalSelectorViewController *)viewController didFinishWithInfo:(NSDictionary*)info {
    LOG( @"info: %@", info );

    [self dismissViewControllerAnimated:YES completion:^{
        LOG(@"dismissed");
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    
    UITableViewCell *cell;
    
    if ([IRKit sharedInstance].numberOfSignals <= indexPath.row) {
        // last line is always "+ New Signal"
        // TODO IRKit SDK provides this?
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewSignalCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"NewSignalCell"];
        }
        cell.textLabel.text = @"+ Add New Signal";
        return cell;
    }
    // otherwise show peripheral info
    cell = [tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierSignal];
    if (cell == nil) {
        cell = [[IRSignalCell alloc] initWithReuseIdentifier:IRKitCellIdentifierSignal];
    }
    ((IRSignalCell*)cell).signal = [[IRKit sharedInstance].signals objectInSignalsAtIndex: indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LOG_CURRENT_METHOD;
    
    switch (section) {
        case 0:
        {
            return [IRKit sharedInstance].numberOfSignals + 1;
        }
    }
    return 0;

}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    {
                        IRSignalSelectorViewController *c = [[IRSignalSelectorViewController alloc] init];
                        c.delegate = (id<IRSignalSelectorViewControllerDelegate>)self;
                        [self presentViewController:c animated:YES completion:^{
                            LOG( @"presented" );
                        }];
                    }
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

@end
