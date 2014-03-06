//
//  IRWifiAdhocViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/01/05.
//
//

#import "Log.h"
#import "IRGuideWifiViewController.h"
#import "IRHTTPClient.h"
#import "IRHelper.h"
#import "IRKit.h"
#import "IRConst.h"

@interface IRGuideWifiViewController ()

@property (nonatomic) id becomeActiveObserver;
@property (nonatomic) IRHTTPClient *doorWaiter;

@end

@implementation IRGuideWifiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
        __weak IRGuideWifiViewController *_self = self;
        _becomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName: UIApplicationDidBecomeActiveNotification
                                                                                  object: nil
                                                                                   queue: [NSOperationQueue mainQueue]
                                                                              usingBlock:^(NSNotification *note) {
            LOG(@"became active");
            [_self processAdhocSetup];
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = IRLocalizedString(@"Connect to IRKit Wi-Fi", @"title of IRGuideWifiViewController");
    [IRViewCustomizer sharedInstance].viewDidLoad(self);

    [self processAdhocSetup];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;

    [_doorWaiter cancel];
    _doorWaiter = nil;

    [IRHTTPClient cancelLocalRequests];
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver: _becomeActiveObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)processAdhocSetup {
    LOG_CURRENT_METHOD;

    [self startWaitingForDoor];
    [self checkAndPostWifiCredentialsIfAdhoc];
}

- (void)startWaitingForDoor {
    if (_doorWaiter) {
        [_doorWaiter cancel];
    }
    __weak IRGuideWifiViewController *_self = self;
    _doorWaiter = [IRHTTPClient waitForDoorWithDeviceID: _keys.deviceid completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        LOG(@"res: %@, error: %@", res, error);

        if (error) {
            return;
        }

        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"New IRKit found!", @"alert title when new IRKit is found")
                                    message: @""
                                   delegate: nil
                          cancelButtonTitle: nil
                          otherButtonTitles: @"OK", nil] show];

        IRPeripheral *p = [[IRKit sharedInstance].peripherals savePeripheralWithName: object[ @"hostname" ]
                                                                            deviceid: _self.keys.deviceid];

        [_self.delegate guideWifiViewController: _self
                              didFinishWithInfo: @{
             IRViewControllerResultType: IRViewControllerResultTypeDone,
             IRViewControllerResultPeripheral: p
         }];
    }];
}

- (void)checkAndPostWifiCredentialsIfAdhoc {
    LOG_CURRENT_METHOD;

    [IRHTTPClient cancelLocalRequests];
    // we don't want to POST wifi credentials without checking it's really IRKit

    __weak IRGuideWifiViewController *_self = self;
    [IRHTTPClient checkIfAdhocWithCompletion:^(NSHTTPURLResponse *res, BOOL isAdhoc, NSError *error) {
        LOG(@"isAdhoc: %d error: %@", isAdhoc, error);
        if (isAdhoc) {
            [IRHTTPClient postWifiKeys: [_self.keys morseStringRepresentation]
                        withCompletion:^(NSHTTPURLResponse *res, id body, NSError *error) {
                    if (res.statusCode == 200) {
                        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"Great! Now let's connect back to your home Wi-Fi", @"alert title after POST /wifi finished successfully")
                                                    message: @""
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil] show];
                    }
                    else {
                        // this can't happen, IRKit responds with non 200 -> 400 when CRC is wrong, but that's not gonna happen
                        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"Something is wrong, please contact developer", @"alert title when POST /wifi failed")
                                                    message: @""
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil] show];
                    }
                }];
        }
        else {
            [_self performSelector: @selector(checkAndPostWifiCredentialsIfAdhoc)
                        withObject: Nil
                        afterDelay: 1.0];
        }
    }];
}

@end
