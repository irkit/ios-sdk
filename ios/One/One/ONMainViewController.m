//
//  ONMainViewController.m
//  One
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "ONMainViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "ONHelper.h"

@interface ONMainViewController ()

@property (nonatomic) id peripheralObserver;
@property (nonatomic) BOOL cancelled;

@end

@implementation ONMainViewController

- (void)viewDidLoad
{
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.separatorColor = [UIColor clearColor];

    _cancelled = NO;

    IRSignals *signals = [[IRSignals alloc] init];
    self.signals = signals;
    [_signals loadFromStandardUserDefaultsKey:@"irkit.signals"];
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver: _peripheralObserver];
}

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:YES];

    // temp!!!!!!!
    _cancelled = YES;

    // show IRNewPeripheralViewController only once
    if (! _cancelled && ([IRKit sharedInstance].numberOfAuthorizedPeripherals == 0)) {
        IRNewPeripheralViewController* c = [[IRNewPeripheralViewController alloc] init];
        c.delegate = (id<IRNewPeripheralViewControllerDelegate>)self;
        [self presentViewController:c
                           animated:YES
                         completion:^{
            LOG( @"presented" );
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
}

- (void)setSignals:(IRSignals *)signals {
    LOG_CURRENT_METHOD;
    _signals = signals;
    signals.delegate = self;
    [self.tableView reloadData];
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

    [ONHelper createIcon:[UIImage imageNamed:@"icon.png"]
              forSignals:_signals
       completionHandler:^(NSHTTPURLResponse *response, NSDictionary *json, NSError *error) {
           LOG( @"response: %@, json: %@, error: %@", response, json, error);
           if (error) {
               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                                   message:nil
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
               [alertView show];
           }
           else {
               NSURL *url = [NSURL URLWithString:json[@"Icon"][@"Url"]];
               [[UIApplication sharedApplication] openURL: url];
           }
       }];
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
    }];
}

#pragma mark - IRNewSignalViewControllerDelegate

- (void)newSignalViewController:(IRNewSignalViewController *)viewController
              didFinishWithInfo:(NSDictionary*)info {
    LOG( @"info: %@", info );

    if ([info[IRViewControllerResultType] isEqual: IRViewControllerResultTypeDone]) {
        [_signals addSignalsObject:info[IRViewControllerResultSignal]];
        [_signals saveToStandardUserDefaultsWithKey:@"irkit.signals"];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        LOG(@"dismissed");
    }];
}

#pragma mark - IRAnimatingControllerDelegate

// animation :)
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
                cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
                cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
                break;
            }
            cell = [_signals tableView:tableView
                 cellForRowAtIndexPath: indexPath];
            cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SelectImageCell"];
            cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
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
                        if (error) {
                            NSString *message;
                            if ([error.domain isEqualToString:@"CBErrorDomain"] && (error.code == 0)) {
                                // IRKit's AVR returns error attributesUserWriteResponse
                                message = @"IRKit error, please restart app and try again";
                            }
                            else {
                                // unknown
                                message = error.description;
                            }
                            // TODO wrap this in IRKit
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                                                message:nil
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                            [alertView show];
                        }
                    }];
                }];
                [sheet addButtonWithTitle:@"Remove" handler:^{
                    [_signals removeSignalsObject:signal];
                    [_signals saveToStandardUserDefaultsWithKey:@"irkit."];
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
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Header1"];
            return cell;
        }
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Header2"];
            return cell;
        }
        default:
            break;
    }
    return nil;
}

@end
