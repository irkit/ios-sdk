#import "Log.h"
#import "IRMorsePlayerViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRWifiEditViewController.h"
#import "IRMorsePlayerOperationQueue.h"
#import "IRMorsePlayerOperation.h"
#import "IRHTTPClient.h"

#define MORSE_WPM 100

@interface IRMorsePlayerViewController ()

@property (nonatomic) IRMorsePlayerOperationQueue *player;

@end

@implementation IRMorsePlayerViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _player = [[IRMorsePlayerOperationQueue alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title = @"Transferring Wifi credentials";
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

- (void)didReceiveMemoryWarning {
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI events

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate morsePlayerViewController:self
                           didFinishWithInfo:@{
           IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

- (IBAction)startButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;

    [IRHTTPClient createKeysWithCompletion: ^(NSArray *keys, NSError *error) {
        if (error) {
            // TODO alert
            return;
        }
        [_keys setKeys:keys];

        NSString *message = [_keys morseStringRepresentation];
        LOG(@"text: %@", message);

        NSNumber *wpm = [NSNumber numberWithInt:MORSE_WPM];
        LOG(@"wpm: %@", wpm);

        [_player addOperation: [IRMorsePlayerOperation playMorseFromString:message
                                                             withWordSpeed:wpm]];
        [_player addOperation: [IRMorsePlayerOperation playMorseFromString:message
                                                             withWordSpeed:wpm]];
        [_player addOperationWithBlock:^{
            // when 2 rounds of morse ended without success,
            // we fail with an alert
            // TODO
            [IRHTTPClient cancelWaitForDoor];
        }];

        [IRHTTPClient waitForDoorWithKey: (NSString*) _keys.mykey
                              completion: ^(NSError* error) {
                                  LOG(@"completion: %@", error);
                                  [_player cancelAllOperations];
                                  if (error) {
                                      // TODO alert
                                  }
        }];
    }];
}

@end
