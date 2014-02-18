#import "Log.h"
#import "IRNewSignalViewController.h"
#import "IRSignal.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRHelper.h"

@interface IRNewSignalViewController ()

@end

@implementation IRNewSignalViewController

- (void)loadView {
    LOG_CURRENT_METHOD;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc] initWithFrame: bounds];

    IRNewSignalScene1ViewController *first = [[IRNewSignalScene1ViewController alloc] initWithNibName: @"IRNewSignalScene1ViewController"
                                                                                               bundle: [IRHelper resources]];
    first.delegate = self;

    _navController = [[UINavigationController alloc] initWithRootViewController: first];
    [view addSubview: _navController.view];

    self.view = view;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear: animated];
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning {
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IRNewSignalScene1ViewControllerDelegate

- (void)scene1ViewController:(IRNewSignalScene1ViewController *)viewController
           didFinishWithInfo:(NSDictionary *)info {
    LOG_CURRENT_METHOD;

    if ([info[IRViewControllerResultType] isEqualToString: IRViewControllerResultTypeCancelled]) {
        [self.delegate newSignalViewController: self
                           didFinishWithSignal: nil];
    }
    ASSERT(1, @"non cancelled results should be handled elsewhere");
}

#pragma mark - IRSignalNameEditViewControllerDelegate

- (void)signalNameEditViewController:(IRSignalNameEditViewController *)viewController
                   didFinishWithInfo:(NSDictionary *)info {
    LOG_CURRENT_METHOD;

    if ([info[IRViewControllerResultType] isEqualToString: IRViewControllerResultTypeDone]) {
        IRSignal *signal = info[IRViewControllerResultSignal];

        [self.delegate newSignalViewController: self
                           didFinishWithSignal: signal];
    }
    else if ([info[IRViewControllerResultType] isEqualToString: IRViewControllerResultTypeCancelled]) {
        [self.delegate newSignalViewController: self
                           didFinishWithSignal: nil];
    }
}

@end
