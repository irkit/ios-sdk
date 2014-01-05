//
//  IRWifiAdhocViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/01/05.
//
//

#import "Log.h"
#import "IRWifiAdhocViewController.h"
#import "IRHTTPClient.h"
#import "IRHelper.h"
#import "IRKit.h"

@interface IRWifiAdhocViewController ()

@property (nonatomic) id becomeActiveObserver;
@property (nonatomic) IRHTTPClient *doorWaiter;

@end

@implementation IRWifiAdhocViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        __weak IRWifiAdhocViewController *_self = self;
        _becomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                  object:nil
                                                                                   queue:[NSOperationQueue mainQueue]
                                                                              usingBlock:^(NSNotification *note) {
                                                                                  LOG( @"became active" );
                                                                                  [_self processAdhocSetup];
                                                                              }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;

    [_doorWaiter cancel];
    [IRHTTPClient cancelWaitForDoor];
    _doorWaiter = nil;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:_becomeActiveObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)processAdhocSetup {
    LOG_CURRENT_METHOD;

    [IRHTTPClient checkIfAdhocWithCompletion:^(NSHTTPURLResponse *res, BOOL isAdhoc, NSError *error) {
        if (isAdhoc) {
            [IRHTTPClient postWifiKeys:[_keys morseStringRepresentation]
                        withCompletion:^(NSHTTPURLResponse *res, id body, NSError *error) {
                            if (res.statusCode == 200) {
                                [[UIAlertView alloc] initWithTitle:IRLocalizedString(@"connect to your home wifi", @"alert title after POST /wifi finished successfully")
                                                           message:@""
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
                            }
                        }];
        }
        else {
            [self startWaitingForDoor];
        }
    }];
}

- (void)startWaitingForDoor {
    if (_doorWaiter) {
        [_doorWaiter cancel];
        [IRHTTPClient cancelWaitForDoor];
    }
    _doorWaiter = [IRHTTPClient waitForDoorWithDeviceID:_keys.deviceid completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        LOG(@"res: %@, error: %@", res, error);

        if (error) {
            return;
        }

        IRPeripheral *p = [[IRKit sharedInstance].peripherals savePeripheralWithName:object[ @"hostname" ]
                                                                            deviceid:_keys.deviceid];

        [self.delegate wifiAdhocViewController:self
                             didFinishWithInfo:@{
                                                 IRViewControllerResultType: IRViewControllerResultTypeDone,
                                                 IRViewControllerResultPeripheral:p
                                                 }];
    }];
}

@end
