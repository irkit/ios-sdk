#import "Log.h"
#import "IRGuidePowerViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRKit.h"
#import "IRWifiEditViewController.h"
#import "IRHelper.h"

@interface IRGuidePowerViewController ()

@end

@implementation IRGuidePowerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title                            = IRLocalizedString(@"Setup IRKit", @"title of IRGuidePowerViewController");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                          target: self
                                                                                          action: @selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: IRLocalizedString(@"Next", @"button title of IRGuidePowerViewController")
                                                                              style: UIBarButtonItemStyleDone
                                                                             target: self
                                                                             action: @selector(doneButtonPressed:)];
    [IRViewCustomizer sharedInstance].viewDidLoad(self);
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent animated: YES];
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear: animated];
}

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear: animated];
}

- (void)didReceiveMemoryWarning {
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI events

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate scene1ViewController: self
                      didFinishWithInfo: @{
         IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

- (void)doneButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate scene1ViewController: self
                      didFinishWithInfo: @{
         IRViewControllerResultType: IRViewControllerResultTypeDone
     }];
}

- (IBAction)buyButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    NSString *url = [NSString stringWithFormat: @"%@/store", APIENDPOINT_BASE];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

@end
