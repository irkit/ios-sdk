//
//  SRMainViewController.m
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/05/17.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "SRMainViewController.h"
#import <BlocksKit/BlocksKit.h>

@interface SRMainViewController ()

@property (nonatomic) IRSignals *signals;
@property (nonatomic) id signalObserver;

@end

@implementation SRMainViewController

- (void)viewDidLoad
{
    LOG_CURRENT_METHOD;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.tableView.delegate   = self;
    self.tableView.dataSource = self;

    _signals = [[IRSignals alloc] init];
    _signals.delegate = self;

    __weak IRSignals *__signals = _signals;
    _signalObserver = [[NSNotificationCenter defaultCenter]
                          addObserverForName:IRKitDidReceiveSignalNotification
                                      object:nil
                                       queue:nil
                                  usingBlock:^(NSNotification *note) {
                                      IRSignal* signal = note.userInfo[IRKitSignalUserInfoKey];
                                      [__signals addSignalsObject:signal];
    }];
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver: _signalObserver];
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
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];
}

- (IBAction)settingsButtonPressed:(id)sender {
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

#pragma mark - IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRNewPeripheralViewController*)viewController
                  didFinishWithInfo:(NSDictionary*)info {
    LOG( @"info: %@", info );
 
    [self dismissViewControllerAnimated:YES completion:^{
        LOG(@"dismissed");
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
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:@"NewSignalCell"];
                }
                cell.textLabel.text = @"+ Add New Signal";
                break;
            }
            cell = [_signals tableView:tableView
                 cellForRowAtIndexPath: indexPath];
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
            return [_signals tableView:tableView
                 numberOfRowsInSection:section] + 1;
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
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:c];
                    [self presentViewController:nav animated:YES completion:^{
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
                    LOG( @"removed: %@", signal );
                }];
                [sheet setCancelButtonWithTitle:nil handler:^{
                    LOG( @"canceled" );
                }];
                [sheet showInView:self.view];
            }
            break;
        case 1:
        case 2:
            {
                NSURL *url = [NSURL URLWithString: @"http://www.google.com/"];
                [[UIApplication sharedApplication] openURL: url];
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
        UIImage *image = [UIImage imageNamed: @"icon.png"];
        UIButton *button = [[UIButton alloc] init];
        [button setBackgroundImage:image forState:UIControlStateNormal];
        button.frame = (CGRect){ (view.frame.size.width - image.size.width)/2.,
                                  50,
                                  image.size.width,
                                  image.size.height };
        [button addEventHandler:^(id sender) {
            LOG( @"tapped" );
            // TODO show icon selector
        } forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }

    return view;
}

@end
