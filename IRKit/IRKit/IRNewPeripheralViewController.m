#import "Log.h"
#import "IRNewPeripheralViewController.h"
#import "IRKit.h"
#import "IRViewCustomizer.h"

@interface IRNewPeripheralViewController ()

@property (nonatomic) UINavigationController *navController;
@property (nonatomic) id becomeActiveObserver;

@end

@implementation IRNewPeripheralViewController

- (void)loadView {
    LOG_CURRENT_METHOD;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc] initWithFrame:bounds];

    NSBundle *main = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];
    IRNewPeripheralScene1ViewController *first = [[IRNewPeripheralScene1ViewController alloc] initWithNibName:@"IRNewPeripheralScene1ViewController"
                                                                                                       bundle:resources];
    first.delegate = self;

    _navController = [[UINavigationController alloc] initWithRootViewController:first];
    [view addSubview:_navController.view];

    self.view = view;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[IRKit sharedInstance] stopScan];
    [[NSNotificationCenter defaultCenter] removeObserver:_becomeActiveObserver];
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);

    [[IRKit sharedInstance] startScan];

    _becomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                              object:nil
                                                                               queue:[NSOperationQueue mainQueue]
                                                                          usingBlock:^(NSNotification *note) {
                                                                              LOG( @"became active" );
                                                                              [[IRKit sharedInstance] startScan];
                                                                          }];
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];

    // hack http://stackoverflow.com/questions/5183834/uinavigationcontroller-within-viewcontroller-gap-at-top-of-view
    // prevent showing the weird 20px empty zone on top of navigationbar
    // when presented in caller's viewDidLoad
//    [_navController setNavigationBarHidden:YES];
//    [_navController setNavigationBarHidden:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:animated];
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IRNewPeripheralScene1ViewControllerDelegate

- (void)scene1ViewController:(IRNewPeripheralScene1ViewController *)viewController
           didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;

    if ([info[IRViewControllerResultType] isEqualToString:IRViewControllerResultTypeCancelled]) {
        [self.delegate newPeripheralViewController:self
                           didFinishWithPeripheral:nil];
    }
    ASSERT(1, @"non cancelled results should be handled elsewhere");
}

#pragma mark - IRNewPeripheralScene2ViewControllerDelegate

- (void)scene2ViewController:(IRNewPeripheralScene2ViewController *)viewController
           didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;

    if ([info[IRViewControllerResultType] isEqualToString:IRViewControllerResultTypeCancelled]) {
        [self.delegate newPeripheralViewController:self
                           didFinishWithPeripheral:nil];
    }
    ASSERT(1, @"non cancelled results should be handled elsewhere");
}

#pragma mark - IRPeripheralNameEditViewControllerDelegate

- (void)nameEditViewController:(IRPeripheralNameEditViewController *)viewController
             didFinishWithInfo:(NSDictionary*)info {
    LOG_CURRENT_METHOD;

    if ([info[IRViewControllerResultType] isEqualToString:IRViewControllerResultTypeDone]) {
        IRPeripheral *peripheral = info[IRViewControllerResultPeripheral];
        [self.delegate newPeripheralViewController:self
                           didFinishWithPeripheral:peripheral];
    }
}

@end
