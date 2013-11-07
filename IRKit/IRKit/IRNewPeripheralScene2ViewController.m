#import "Log.h"
#import "IRNewPeripheralScene2ViewController.h"
#import "IRPeripheralNameEditViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"

@interface IRNewPeripheralScene2ViewController ()

@property (nonatomic) id observer;
@property (nonatomic) BOOL didAlreadyAuthenticate;

@end

@implementation IRNewPeripheralScene2ViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _didAlreadyAuthenticate = NO;
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title = @"Waiting for Pairing...";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelButtonPressed:)];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:animated];

    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:IRKitDidAuthenticatePeripheralNotification
                                                                  object:nil
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *note) {
                                                                  LOG( @"irkit authenticated");
                                                                  [self didAuthenticate];
                                                              }];
    if (_peripheral.authenticated) {
        [self didAuthenticate];
        return;
    }
    [_peripheral startAuthPolling];
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}

- (void) didAuthenticate {
    LOG_CURRENT_METHOD;

    if (_didAlreadyAuthenticate) {
        return;
    }
    _didAlreadyAuthenticate = YES;
    [_peripheral stopAuthPolling];

    [[NSNotificationCenter defaultCenter] removeObserver:_observer];

    NSBundle *main = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];
    IRPeripheralNameEditViewController *c = [[IRPeripheralNameEditViewController alloc] initWithNibName:@"IRPeripheralNameEditViewController"
                                                                                                   bundle:resources];
    c.delegate = (id<IRPeripheralNameEditViewControllerDelegate>)self.delegate;
    c.peripheral = _peripheral;
    [self.navigationController pushViewController:c
                                         animated:YES];
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate scene2ViewController:self
                      didFinishWithInfo:@{
             IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

@end
