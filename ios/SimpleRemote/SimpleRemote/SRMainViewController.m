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
    
    switch (indexPath.section) {
        case 0:
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
                break;
            }
            cell = [[IRKit sharedInstance].signals tableView:tableView cellForRowAtIndexPath: indexPath];
            break;
        case 1:
            break;
        case 2:
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:@"NewSignalCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"NewSignalCell"];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Go!";
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LOG_CURRENT_METHOD;

    switch (section) {
        case 0:
            return [[IRKit sharedInstance].signals tableView:tableView numberOfRowsInSection:section] + 1;
        case 1:
            return 0;
        case 2:
        default:
            return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LOG_CURRENT_METHOD;
    return 3;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    switch (section) {
        case 0:
            return 60.;
        case 1:
            return 110.;
        case 2:
        default:
            return 60.;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    float offsetLeft = 20.;
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){0.,0.,320.,50.}];
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){ offsetLeft, 0., 320.-offsetLeft,50.}];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:32];
    switch (section) {
        case 0:
            label.text = @"1 Select Signal";
            break;
        case 1:
            label.text = @"2 Select Icon Image";
            break;
        case 2:
        default:
            label.text = @"3 Create App Icon";
            break;
    }
    [view addSubview:label];

    if (section == 1) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.png"]];
        imageView.frame = (CGRect){ (view.frame.size.width - imageView.frame.size.width)/2.,
                                    50,
                                    imageView.frame.size.width,
                                    imageView.frame.size.height };
        [view addSubview:imageView];
    }

    return view;
}

@end
