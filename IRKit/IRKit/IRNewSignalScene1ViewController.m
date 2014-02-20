#import "Log.h"
#import "IRNewSignalScene1ViewController.h"
#import "IRSignal.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRSignalNameEditViewController.h"
#import "IRHTTPClient.h"
#import "IRKit.h"
#import "IRHelper.h"

@interface IRNewSignalScene1ViewController ()

@property (nonatomic) IRHTTPClient *waiter;

@end

@implementation IRNewSignalScene1ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title                            = IRLocalizedString(@"Waiting for Signal ...", @"title of IRNewSignalScene1");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                  target: self
                                                                  action: @selector(cancelButtonPressed:)];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear: animated];
}

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear: animated];

    __weak IRNewSignalScene1ViewController *_self = self;
    _waiter = [IRHTTPClient waitForSignalWithCompletion:^(NSHTTPURLResponse *res, IRSignal *signal, NSError *error) {
        if (signal) {
            [_self didReceiveSignal: signal];
        }
        else {
            [_self cancelButtonPressed: nil];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear: animated];

    [_waiter cancel];
    _waiter = nil;
}

- (void)didReceiveSignal:(IRSignal *)signal {
    LOG_CURRENT_METHOD;

    IRSignalNameEditViewController *c = [[IRSignalNameEditViewController alloc] initWithNibName: @"IRSignalNameEditViewController"
                                                                                         bundle: [IRHelper resources]];
    c.delegate = (id<IRSignalNameEditViewControllerDelegate>)self.delegate;
    c.signal   = signal;
    [self.navigationController pushViewController: c
                                         animated: YES];
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning {
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;

    [self.delegate scene1ViewController: self
                      didFinishWithInfo: @{
         IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

@end
