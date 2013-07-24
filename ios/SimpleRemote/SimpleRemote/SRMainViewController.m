//
//  SRMainViewController.m
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "SRMainViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "SRHelper.h"

@interface SRMainViewController ()

@property (nonatomic) IRSignals *signals;
@property (nonatomic) id signalObserver;
@property (nonatomic) id peripheralObserver;
@property (nonatomic) BOOL showingNewPeripheralViewController;
@property (nonatomic) BOOL cancelled;

@end

@implementation SRMainViewController

- (void)viewDidLoad
{
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.tableView.delegate   = self;
    self.tableView.dataSource = self;

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSData *data = [d objectForKey: @"signals"];
    _signals = [[IRSignals alloc] init];
    [_signals loadFromData:data];
    _signals.delegate = self;

    __weak SRMainViewController *_self = self;
    _signalObserver = [[NSNotificationCenter defaultCenter]
                          addObserverForName:IRKitDidReceiveSignalNotification
                                      object:nil
                                       queue:nil
                                  usingBlock:^(NSNotification *note) {
                                      IRSignal* signal = note.userInfo[IRKitSignalUserInfoKey];
                                      [_self.signals addSignalsObject:signal];
                                      [_self saveSignals];
    }];
    // show view controller when another peripheral is found
    _peripheralObserver = [[NSNotificationCenter defaultCenter]
                           addObserverForName:IRKitDidDiscoverUnauthorizedPeripheralNotification
                                       object:nil
                                        queue:nil
                                   usingBlock:^(NSNotification *note) {
                                       if (_showingNewPeripheralViewController) {
                                           return;
                                       }
                                       IRNewPeripheralViewController* c = [[IRNewPeripheralViewController alloc] init];
                                       c.delegate = (id<IRNewPeripheralViewControllerDelegate>)self;
                                       [self presentViewController:c
                                                          animated:YES
                                                        completion:^{
                                           LOG( @"presented" );
                                           _showingNewPeripheralViewController = YES;
                                       }];
                                   } ];

    // customize left bar button
    UIBarButtonItem *left = self.navigationItem.leftBarButtonItem;
    UIImage *bgImage = [UIImage imageNamed:@"icn_actionbar_menu.png"];
    UIImage *bgImageReal = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(28, 24, 0, 0)];

    [left setBackgroundImage:bgImageReal
                    forState:UIControlStateNormal
                  barMetrics:UIBarMetricsDefault];
    [left setBackgroundVerticalPositionAdjustment:5. forBarMetrics:UIBarMetricsDefault];

    _cancelled = NO;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver: _signalObserver];
    [[NSNotificationCenter defaultCenter] removeObserver: _peripheralObserver];
}

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:YES];

    // temp
    _cancelled = YES;
    
    if (! _cancelled && ([IRKit sharedInstance].numberOfAuthorizedPeripherals == 0)) {
        IRNewPeripheralViewController* c = [[IRNewPeripheralViewController alloc] init];
        c.delegate = (id<IRNewPeripheralViewControllerDelegate>)self;
        [self presentViewController:c
                           animated:YES
                         completion:^{
            LOG( @"presented" );
            _showingNewPeripheralViewController = YES;
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];
}

- (void)saveSignals {
    NSUserDefaults *d2 = [NSUserDefaults standardUserDefaults];
    [d2 setObject:_signals.data
           forKey:@"signals"];
    [d2 synchronize];
}

#pragma mark - UI events

- (IBAction)settingsButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    
    IRNewPeripheralViewController* c = [[IRNewPeripheralViewController alloc] init];
    c.delegate = (id<IRNewPeripheralViewControllerDelegate>)self;
    [self presentViewController:c
                       animated:YES
                     completion:^{
        LOG( @"presented" );
    }];
}

- (IBAction)createIconPressed:(id)sender {
    LOG_CURRENT_METHOD;

//    [SRHelper uploadIcon: nil
//              withIRData: nil
//              withIRFreq: 38
//       completionHandler: ^(NSHTTPURLResponse *response, NSDictionary *json, NSError *error) {
//           LOG( @"response: %@, json: %@, error: %@", response, json, error);
//           [[UIApplication sharedApplication] openURL: json[@"Icon"][@"Url"]];
//       }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRNewPeripheralViewController*)viewController
                  didFinishWithInfo:(NSDictionary*)info {
    LOG( @"info: %@", info );
 
    if ([info[IRViewControllerResultType] isEqualToString: IRViewControllerResultTypeCancelled]) {
        _cancelled = YES;
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
        LOG(@"dismissed");
        _showingNewPeripheralViewController = NO;
    }];
}

#pragma mark - IRNewSignalViewControllerDelegate

- (void)newSignalViewController:(IRNewSignalViewController *)viewController
              didFinishWithInfo:(NSDictionary*)info {
    LOG( @"info: %@", info );
    // we're gonna show new signals even without using IRNewSignalViewController used
//    if ([info[IRViewControllerResultType] isEqual: IRViewControllerResultTypeDone]) {
//        [_signals addSignalsObject:info[IRViewControllerResultSignal]];
//        [_signals save];
//    }
    [self dismissViewControllerAnimated:YES completion:^{
        LOG(@"dismissed");
    }];
}

#pragma mark - IRAnimatingControllerDelegate

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

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            if (_signals.countOfSignals <= indexPath.row) {
                // last line is always "+ Add New Signal"
                cell = [tableView dequeueReusableCellWithIdentifier:@"NewSignalCell"];
                break;
            }
            cell = [_signals tableView:tableView
                 cellForRowAtIndexPath: indexPath];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SelectImageCell"];
            break;
        case 2:
        default:
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LOG_CURRENT_METHOD;

    switch (section) {
        case 0:
            return [_signals tableView:tableView
                 numberOfRowsInSection:section] + 1;
        case 1:
            return 1;
        case 2:
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LOG_CURRENT_METHOD;
    return 2;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    switch (indexPath.section) {
        case 0:
            if (indexPath.row >= _signals.countOfSignals) {
                return 44;
            }
            return [_signals tableView: tableView
               heightForRowAtIndexPath: indexPath];
        case 1:
            return 80;
        case 2:
        default:
            return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
            {
                if (_signals.countOfSignals <= indexPath.row) {
                    // pressed Add New Signal cell
                    IRNewSignalViewController *c = [[IRNewSignalViewController alloc] init];
                    c.delegate = (id<IRNewSignalViewControllerDelegate>)self;
                    [self presentViewController:c
                                       animated:YES
                                     completion:^{
                        LOG( @"presented" );
                    }];
                    return;
                }
                IRSignal *signal = [_signals objectAtIndex: indexPath.row];
                UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:@"Please select one."];
                [sheet addButtonWithTitle:@"Test Send" handler:^{
                    [signal sendWithCompletion:^(NSError *error) {
                        LOG( @"sent: %@", error );
                    }];
                }];
                [sheet addButtonWithTitle:@"Remove" handler:^{
                    [_signals removeSignalsObject:signal];
                    [self saveSignals];
                    LOG( @"removed: %@", signal );
                }];
                [sheet setCancelButtonWithTitle:nil handler:^{
                    LOG( @"canceled" );
                }];
                [sheet showInView:self.view];
            }
            break;
        case 1:
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    switch (section) {
        case 0:
            return 40;
        case 1:
            return 40;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    switch (section) {
        case 0:
        case 1:
        case 2:
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SRMainTableHeaderViews" owner:self options:nil];
            return [topLevelObjects objectAtIndex:section];
        }
        default:
            break;
    }
    return nil;
}

@end
