#import "Log.h"
#import "IRNewPeripheralViewController.h"
#import "IRViewCustomizer.h"
#import "IRHelper.h"
#import "IRConst.h"
#import "IRKeys.h"
#import "IRKit.h"
#import "IRHTTPClient.h"

@interface IRNewPeripheralViewController ()

@property (nonatomic) id becomeActiveObserver;
@property (nonatomic) IRKeys *keys;
@property (nonatomic) IRPeripheral *foundPeripheral;

// don't search for IRKit device after stopSearch was called
// we don't want to see timing problems of which (POST /1/door response or Bonjour) is faster to detect online IRKit
// prioritize POST /1/door response, and stop searching Bonjour after showing WifiEditVC
@property (nonatomic) BOOL stopSearchCalled;

@property (nonatomic) UIAlertView *currentAlertView;

@end

@implementation IRNewPeripheralViewController

- (void)loadView {
    LOG_CURRENT_METHOD;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIView *view  = [[UIView alloc] initWithFrame: bounds];

    IRGuidePowerViewController *first = [[IRGuidePowerViewController alloc] initWithNibName: @"IRGuidePowerViewController"
                                                                                     bundle: [IRHelper resources]];
    first.delegate = self;

    _navController = [[UINavigationController alloc] initWithRootViewController: first];
    [view addSubview: _navController.view];

    self.view = view;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;

    _currentAlertView.delegate = nil;

    [self stopSearch];
    [[NSNotificationCenter defaultCenter] removeObserver: _becomeActiveObserver];
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    _keys = [[IRKeys alloc] init];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);

    __weak IRNewPeripheralViewController *_self = self;
    _becomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName: UIApplicationDidBecomeActiveNotification
                                                                              object: nil
                                                                               queue: [NSOperationQueue mainQueue]
                                                                          usingBlock:^(NSNotification *note) {
        LOG(@"became active");
        if (!_self.stopSearchCalled) {
            [_self startSearch];
        }
        [_self registerDeviceIfNeeded];
    }];
    [self startSearch];
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear: animated];
}

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear: animated];
}

- (void)registerDeviceIfNeeded {
    if (!_keys.keysAreSet) {
        [IRHTTPClient registerDeviceWithCompletion: ^(NSHTTPURLResponse *res, NSDictionary *keys, NSError *error) {
            if (error) {
                return;
            }
            [_keys setKeys: keys];
        }];
    }
}

#pragma mark - IRSearcher related

// start searching for the first 30 seconds,
// if no new IRKit device found, stop then
- (void)startSearch {
    LOG_CURRENT_METHOD;
    _stopSearchCalled = false;

    [IRSearcher sharedInstance].delegate = self;
    [[IRSearcher sharedInstance] startSearching];
}

- (void)stopSearch {
    LOG_CURRENT_METHOD;
    _stopSearchCalled = YES;

    [[IRSearcher sharedInstance] stop];
}

#pragma mark - IRSearcherDelegate

- (void)searcher:(IRSearcher *)searcher didResolveService:(NSNetService *)service {
    LOG(@"service: %@", service);
    IRPeripherals *peripherals = [IRKit sharedInstance].peripherals;

    NSString *name  = [service.hostName componentsSeparatedByString: @"."][ 0 ];
    IRPeripheral *p = [peripherals peripheralWithName: name];
    if (!p) {
        p = [peripherals registerPeripheralWithName: name];
        [peripherals save];
    }
    if (!p.deviceid) {
        __weak typeof(self) _self = self;
        [p getKeyWithCompletion:^{
            [peripherals save];
            _self.foundPeripheral = p;      // temporary retain, til alert dismisses

            // avoid
            // nested push animation can result in corrupted navigation bar
            // Finishing up a navigation transition in an unexpected state. Navigation Bar subview tree might get corrupted.
            // pushViewController after alertview is dismissed
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: IRLocalizedString(@"New IRKit found!", @"alert title when new IRKit is found")
                                                            message: @""
                                                           delegate: self
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: @"OK", nil];
            _self.currentAlertView = alert;
            [alert show];
        }];
    }
}

- (void)searcherWillStartSearching:(IRSearcher *)searcher {
    LOG_CURRENT_METHOD;
}

- (void)searcherDidTimeout:(IRSearcher *)searcher {
    LOG_CURRENT_METHOD;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    LOG_CURRENT_METHOD;

    _currentAlertView = nil;

    IRPeripheralNameEditViewController *c = [[IRPeripheralNameEditViewController alloc] initWithNibName: @"IRPeripheralNameEditViewController" bundle: [IRHelper resources]];
    c.delegate       = self;
    c.peripheral     = _foundPeripheral;
    _foundPeripheral = nil;
    [self.navController pushViewController: c animated: YES];
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning {
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IRGuidePowerViewControllerDelegate

- (void)scene1ViewController:(IRGuidePowerViewController *)viewController
           didFinishWithInfo:(NSDictionary *)info {
    LOG_CURRENT_METHOD;

    if ([info[IRViewControllerResultType] isEqualToString: IRViewControllerResultTypeCancelled]) {
        [self.delegate newPeripheralViewController: self
                           didFinishWithPeripheral: nil];
        return;
    }

    // do here, to make sure request against POST /1/clients is finished
    [self registerDeviceIfNeeded];

    IRWifiEditViewController *c = [[IRWifiEditViewController alloc] initWithNibName: @"IRWifiEditViewController"
                                                                             bundle: [IRHelper resources]];
    c.delegate = self;
    c.keys     = _keys;
    [self.navController pushViewController: c animated: YES];
}

#pragma mark - IRWifiEditViewControllerDelegate

- (void)wifiEditViewController:(IRWifiEditViewController *)viewController didFinishWithInfo:(NSDictionary *)info {
    LOG_CURRENT_METHOD;

    if ([info[IRViewControllerResultType] isEqualToString: IRViewControllerResultTypeCancelled]) {
        [self.delegate newPeripheralViewController: self
                           didFinishWithPeripheral: nil];
        return;
    }

    if (!_keys.keysAreSet) {
        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"Check your internet connection. Connect to your home Wi-Fi network first.", @"alert view title when ! keysAreSet")
                                    message: @""
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [self.delegate newPeripheralViewController: self
                           didFinishWithPeripheral: nil];
        return;
    }

    [self stopSearch];

    IRGuideWifiViewController *c = [[IRGuideWifiViewController alloc] initWithNibName: @"IRGuideWifiViewController" bundle: [IRHelper resources]];
    c.delegate = self;
    c.keys     = _keys;
    [self.navController pushViewController: c animated: YES];
}

#pragma mark - IRGuideWifiViewControllerDelegate

- (void)guideWifiViewController:(IRGuideWifiViewController *)viewController
              didFinishWithInfo:(NSDictionary *)info {
    LOG_CURRENT_METHOD;

    if (![info[IRViewControllerResultType] isEqualToString: IRViewControllerResultTypeDone]) {
        [self.delegate newPeripheralViewController: self
                           didFinishWithPeripheral: nil];
        return;
    }

    IRPeripheral *p = info[IRViewControllerResultPeripheral];
    if (p) {
        IRPeripheralNameEditViewController *c = [[IRPeripheralNameEditViewController alloc] initWithNibName: @"IRPeripheralNameEditViewController" bundle: [IRHelper resources]];
        c.delegate   = self;
        c.peripheral = p;
        [self.navController pushViewController: c animated: YES];
    }
}

#pragma mark - IRPeripheralNameEditViewControllerDelegate

- (void)nameEditViewController:(IRPeripheralNameEditViewController *)viewController
             didFinishWithInfo:(NSDictionary *)info {
    LOG_CURRENT_METHOD;

    if ([info[IRViewControllerResultType] isEqualToString: IRViewControllerResultTypeDone]) {
        IRPeripheral *peripheral = info[IRViewControllerResultPeripheral];
        [self.delegate newPeripheralViewController: self
                           didFinishWithPeripheral: peripheral];
    }
}

@end
