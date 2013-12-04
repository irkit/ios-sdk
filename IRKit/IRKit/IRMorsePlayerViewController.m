#import "Log.h"
#import "IRMorsePlayerViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRWifiEditViewController.h"
#import "IRMorsePlayerOperationQueue.h"
#import "IRMorsePlayerOperation.h"
#import "IRHTTPClient.h"
#import "IRKit.h"
#import "MediaPlayer/MPVolumeView.h"

#define MORSE_WPM 100

@interface IRMorsePlayerViewController ()

@property (nonatomic) IRMorsePlayerOperationQueue *player;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumeView;
@property (nonatomic) BOOL playing;

@property (nonatomic, copy) NSString *morseMessage;
@property (nonatomic) IRHTTPClient *doorWaiter;

@end

@implementation IRMorsePlayerViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _player = [[IRMorsePlayerOperationQueue alloc] init];
        _volumeView.showsRouteButton = false;
        _playing = false;
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

#pragma mark - Private

- (void)startPlaying {
    LOG_CURRENT_METHOD;

    _playing = true;

    _morseMessage = [_keys morseStringRepresentation];
    LOG(@"morseMessage: %@", _morseMessage);

    [_player addObserver:self
              forKeyPath:@"operationCount"
                 options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                 context:nil];
    // fire key value observer
    [self observeValueForKeyPath:@"operationCount"
                        ofObject:nil
                          change:@{ NSKeyValueChangeNewKey: @0 }
                         context:nil];
}

- (void)stopPlaying {
    LOG_CURRENT_METHOD;

    [_doorWaiter cancel];
    [IRHTTPClient cancelWaitForDoor];

    [_player removeObserver:self
                 forKeyPath:@"operationCount"];
    [_player cancelAllOperations];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    LOG( @"keyPath: %@", keyPath );

    if ([keyPath isEqualToString:@"operationCount"]) {
        NSObject *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (newValue &&
            ([(NSNumber*)newValue unsignedIntegerValue]==0)) {
            [_player addOperation: [IRMorsePlayerOperation playMorseFromString:_morseMessage
                                                                 withWordSpeed:[NSNumber numberWithInt:MORSE_WPM]]];
        }
    }

}

#pragma mark - UI events

- (void)cancelButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;

    [self stopPlaying];

    [self.delegate morsePlayerViewController:self
                           didFinishWithInfo:@{
           IRViewControllerResultType: IRViewControllerResultTypeCancelled
     }];
}

- (IBAction)startButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;

    [IRHTTPClient createKeysWithCompletion: ^(NSHTTPURLResponse *res, NSArray *keys, NSError *error) {
        if (error) {
            // TODO alert
            return;
        }
        [_keys setKeys:keys];

        [self startPlaying];

        _doorWaiter =
            [IRHTTPClient waitForDoorWithKey: (NSString*) _keys.mykey
                                  completion: ^(NSHTTPURLResponse* res, id object, NSError* error) {
                                      LOG(@"res: %@, error: %@", res, error);

                                      [self stopPlaying];

                                      if (error) {
                                          // TODO alert
                                          return;
                                      }

                                      NSString *name = object[ @"name" ];
                                      IRKit *i = [IRKit sharedInstance];
                                      IRPeripheral *p = [i.peripherals IRPeripheralForName:name];
                                      if ( ! p ) {
                                          p = [i.peripherals registerPeripheralWithName:name];
                                          p.key = _keys.mykey;
                                          [i.peripherals save];
                                          [p getModelNameAndVersionWithCompletion:^{
                                              [i.peripherals save];
                                          }];
                                      }

                                      [self.delegate morsePlayerViewController:self
                                                             didFinishWithInfo:@{
                                                                                 IRViewControllerResultType: IRViewControllerResultTypeDone,
                                                                                 IRViewControllerResultPeripheral:p
                                                                                 }];
                              }];
    }];
}

@end
