//
//  IRWifiAdhocViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/01/05.
//
//
// successful behaviour:
// viewDidLoad
// launch settings app, connect to IRKit wi-fi, back to our app
// DidBecomeActive
// show HUD
// wait til GET / against 192.168.1.1 succeeds
// POST /wifi
// hide HUD
// alert("connect to home wi-fi")
// launch settings app, connect to home wi-fi, back to our app
// DidBecomeActive
// show HUD
// wait til POST /1/door succeeds
// hide HUD
// finish


#import "Log.h"
#import "IRGuideWifiViewController.h"
#import "IRHTTPClient.h"
#import "IRHelper.h"
#import "IRKit.h"
#import "IRConst.h"
#import "IRProgressView.h"

const NSTimeInterval kIntervalToHideHUD  = 0.3;
const NSTimeInterval kWiFiConnectTimeout = 15.0;

@interface IRGuideWifiViewController ()

@property (nonatomic) id becomeActiveObserver;
@property (nonatomic) IRHTTPClient *doorWaiter;
@property (nonatomic) BOOL postWifiSucceeded;
@property (nonatomic) NSDate *becameActiveAt;

@end

@implementation IRGuideWifiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
        __weak typeof(self) _self = self;
        _becomeActiveObserver     = [[NSNotificationCenter defaultCenter] addObserverForName: UIApplicationDidBecomeActiveNotification
                                                                                      object: nil
                                                                                       queue: [NSOperationQueue mainQueue]
                                                                                  usingBlock:^(NSNotification *note) {
            LOG(@"became active");
            _self.becameActiveAt = [NSDate date];

            // show HUD
            [IRProgressView showHUDAddedTo: _self.navigationController.view];

            if (!_self.postWifiSucceeded) {
                [_self checkAndPostWifiCredentialsIfAdhoc];
            }
            else {
                [_self startWaitingForDoor];
            }
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = IRLocalizedString(@"Connect to IRKit Wi-Fi", @"title of IRGuideWifiViewController");
    [IRViewCustomizer sharedInstance].viewDidLoad(self);

    _postWifiSucceeded = NO;
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

- (void)checkAndPostWifiCredentialsIfAdhoc {
    LOG_CURRENT_METHOD;

    [IRHTTPClient cancelLocalRequests];

    // We don't want to POST wifi credentials without checking it's really IRKit
    // It's "Server" header prefix must be "IRKit/"

    __weak typeof(self) _self = self;
    [IRHTTPClient checkIfAdhocWithCompletion:^(NSHTTPURLResponse *res, BOOL isAdhoc, NSError *error) {
        LOG(@"isAdhoc: %d error: %@", isAdhoc, error);

        if (error && (error.code == NSURLErrorTimedOut) && ([error.domain isEqualToString: NSURLErrorDomain])) {
            // if we've waited for XX seconds
            // we must haven't been connected to IRKit's Wi-Fi
            if ([[NSDate date] timeIntervalSinceDate: _self.becameActiveAt] > kWiFiConnectTimeout) {
                [_self alertAndHideHUD];
                return;
            }
            // retry if timeout
            LOG( @"retrying" );
            [_self performSelector: @selector(checkAndPostWifiCredentialsIfAdhoc)
                        withObject: Nil
                        afterDelay: 1.0];
            return;
        }

        if (isAdhoc) {

            NSString *localIP = [IRHelper localIPAddress];
            LOG( @"local IP: %@", localIP );
            NSRange found = [localIP rangeOfString: @"192.168.1."];
            if (found.location == NSNotFound) {
                // local IP must be 192.168.1.X when connected to IRKit wi-fi
                [_self alertAndHideHUD];
                return;
            }

            [IRHTTPClient postWifiKeys: [_self.keys morseStringRepresentation]
                        withCompletion: ^(NSHTTPURLResponse *res, id body, NSError *error) {

                    // hide HUD
                    [IRProgressView hideHUDForView: _self.navigationController.view afterDelay: kIntervalToHideHUD];

                    if (res.statusCode == 200) {
                        _self.postWifiSucceeded = YES;

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

            LOG( @"what?!" );

        }
    }];
}

- (void) alertAndHideHUD {
    [IRProgressView hideHUDForView: self.navigationController.view afterDelay: kIntervalToHideHUD];

    [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"Open Settings app and connect to a Wi-Fi network named like IRKitXXXX", @"alert title when reachable")
                                message: @""
                               delegate: nil
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
}

- (void)startWaitingForDoor {
    if (_doorWaiter) {
        [_doorWaiter cancel];
    }
    __weak typeof(self) _self = self;
    _doorWaiter               = [IRHTTPClient waitForDoorWithDeviceID: _keys.deviceid completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        if (error) {
            return;
        }

        // hide HUD immediately
        [IRProgressView hideHUDForView: _self.navigationController.view afterDelay: 0];

        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"New IRKit found!", @"alert title when new IRKit is found")
                                    message: @""
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];

        IRPeripheral *p = [[IRKit sharedInstance].peripherals savePeripheralWithName: object[ @"hostname" ]
                                                                            deviceid: _self.keys.deviceid];

        [_self.delegate guideWifiViewController: _self
                              didFinishWithInfo: @{
             IRViewControllerResultType: IRViewControllerResultTypeDone,
             IRViewControllerResultPeripheral: p
         }];
    }];
}

@end
