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

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];

    [IRKit sharedInstance].signals.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];

    [IRKit sharedInstance].signals.delegate = nil;
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
#pragma mark IRAnimatingControllerDelegate

- (void)controller:(id)controller
   didChangeObject:(id)object
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(IRAnimatingType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    LOG( @"object: %@ changeType: %d newIndexPath: %@", object, type, newIndexPath );
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case IRAnimatingTypeInsert:
            [tableView beginUpdates];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
            break;
            
        case IRAnimatingTypeDelete:
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
            break;
    }
}

- (void) controllerDidChangeContent:(id)controller {
    LOG_CURRENT_METHOD;
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

//        int margin = 20;
//        int height = 100;
//        IRChartView *chartView = [[IRChartView alloc] initWithFrame: (CGRect){ margin, margin, 300 - margin*2, height - margin*2 }];
//        chartView.data = @[ @1000, @500, @500 ];
//        [cell.contentView addSubview: chartView];
        return cell;
    }
    return [[IRKit sharedInstance].signals tableView:tableView cellForRowAtIndexPath: indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LOG_CURRENT_METHOD;

    return [[IRKit sharedInstance].signals tableView:tableView numberOfRowsInSection:section] + 1;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    if ([IRKit sharedInstance].numberOfSignals <= indexPath.row) {
        return 44;
    }
    return [[IRKit sharedInstance].signals tableView: tableView
                             heightForRowAtIndexPath: indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
            {
                if (indexPath.row < [IRKit sharedInstance].numberOfSignals) {
                    IRSignal *signal = [[IRKit sharedInstance].signals objectAtIndex: indexPath.row];
                    [signal sendWithCompletion:^(NSError *error) {
                        LOG( @"sent: %@", error );
                    }];
                    return;
                }
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
}

@end
