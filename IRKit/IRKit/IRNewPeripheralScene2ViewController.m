#import "Log.h"
#import "IRNewPeripheralScene2ViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"

@interface IRNewPeripheralScene2ViewController ()

@end

@implementation IRNewPeripheralScene2ViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title = @"Prepare for Morse";
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
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];
}

- (void) didAuthenticate {
    LOG_CURRENT_METHOD;
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

- (IBAction)doneButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate scene2ViewController:self
                      didFinishWithInfo:@{
            IRViewControllerResultType: IRViewControllerResultTypeDone
    }];
}

@end
