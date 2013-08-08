#import "Log.h"
#import "IRNewSignalScene1ViewController.h"
#import "IRSignal.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRSignalNameEditViewController.h"

@interface IRNewSignalScene1ViewController ()

@property (nonatomic) id observer;

@end

@implementation IRNewSignalScene1ViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title = @"Waiting for Signal ...";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self
                                             action:@selector(cancelButtonPressed:)];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:animated];

    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:IRKitDidReceiveSignalNotification
                                                                  object:nil
                                                                   queue:nil
                                                              usingBlock:^(NSNotification *note) {
                                                                  IRSignal* signal = note.userInfo[IRKitSignalUserInfoKey];
                                                                  [self didReceiveSignal:signal];
                                                              }];
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}

- (void) didReceiveSignal: (IRSignal*)signal {
    LOG_CURRENT_METHOD;

    [[NSNotificationCenter defaultCenter] removeObserver:_observer];

    NSBundle *main = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];
    IRSignalNameEditViewController *c = [[IRSignalNameEditViewController alloc] initWithNibName:@"IRSignalNameEditViewController"
                                                                                           bundle:resources];
    c.delegate = self.delegate;
    c.signal   = signal;
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

    [self.delegate scene1ViewController:self
                      didFinishWithInfo:@{
           IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

@end
