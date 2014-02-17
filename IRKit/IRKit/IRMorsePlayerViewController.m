#import "Log.h"
#import "IRMorsePlayerViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRWifiEditViewController.h"
#import "IRMorsePlayerOperationQueue.h"
#import "IRMorsePlayerOperation.h"
#import "IRHTTPClient.h"
#import "IRKit.h"
#import "IRHelper.h"
#import "IRWifiAdhocViewController.h"
@import MediaPlayer;

#define MORSE_WPM 100

@interface IRMorsePlayerViewController ()

@property (weak, nonatomic) IBOutlet UIView *startButtonBox;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumeView;
@property (weak, nonatomic) IBOutlet UIView *fullscreenBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *animatingImageView;
@property (weak, nonatomic) IBOutlet UIButton *morseNotWorkingButton;

@property (nonatomic) id volumeChangedObserver;

@property (nonatomic) IRMorsePlayerOperationQueue *player;
@property (nonatomic) BOOL playing;
@property (nonatomic) BOOL shownStartButtonView;

@property (nonatomic, copy) NSString *morseMessage;
@property (nonatomic) IRHTTPClient *doorWaiter;

@end

@implementation IRMorsePlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _player = [[IRMorsePlayerOperationQueue alloc] init];

        _playing = false;
        _shownStartButtonView = false;

        [_player addObserver:self
                  forKeyPath:@"operationCount"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];

        __weak IRMorsePlayerViewController *_self = self;
        _volumeChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                                                   object:nil
                                                                                    queue:[NSOperationQueue mainQueue]
                                                                               usingBlock:^(NSNotification *note) {
            float volume = [[[note userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
            LOG(@"volume: %f", volume);
            [_self updateStartButtonViewWithVolume:volume];
        }];
    }
    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [_player removeObserver:self
                 forKeyPath:@"operationCount"];
    [[NSNotificationCenter defaultCenter] removeObserver:_volumeChangedObserver];
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title = IRLocalizedString(@"WiFi Morse Setup", @"title of IRMorsePlayer");

    [IRViewCustomizer sharedInstance].viewDidLoad(self);

    _volumeView.showsRouteButton = false;

    // hide it initially
    _startButtonBox.hidden = YES;
    _fullscreenBackgroundView.hidden = YES;
    _animatingImageView.hidden = YES;

    _morseNotWorkingButton.hidden = !_showMorseNotWorkingButton;

    // TODO deprecated
    [self updateStartButtonViewWithVolume:[[MPMusicPlayerController applicationMusicPlayer] volume]];
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];

    [self stopPlaying];
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

    // setup views

    _fullscreenBackgroundView.hidden = NO;
    _fullscreenBackgroundView.alpha = 0;
    _animatingImageView.hidden = NO;
    _animatingImageView.alpha = 0;
    _animatingImageView.animationImages = @[
        [IRHelper imageInResourceNamed:@"anime_01"],
        [IRHelper imageInResourceNamed:@"anime_02"],
        [IRHelper imageInResourceNamed:@"anime_03"],
        [IRHelper imageInResourceNamed:@"anime_04"],
        [IRHelper imageInResourceNamed:@"anime_05"],
        [IRHelper imageInResourceNamed:@"anime_06"],
        [IRHelper imageInResourceNamed:@"anime_07"],
        [IRHelper imageInResourceNamed:@"anime_08"],
        [IRHelper imageInResourceNamed:@"anime_09"],
        [IRHelper imageInResourceNamed:@"anime_10"],
        [IRHelper imageInResourceNamed:@"anime_11"],
        [IRHelper imageInResourceNamed:@"anime_12"],
        [IRHelper imageInResourceNamed:@"anime_13"],
        [IRHelper imageInResourceNamed:@"anime_14"],
        [IRHelper imageInResourceNamed:@"anime_15"],
        [IRHelper imageInResourceNamed:@"anime_16"],
        [IRHelper imageInResourceNamed:@"anime_17"],
        [IRHelper imageInResourceNamed:@"anime_18"],
        [IRHelper imageInResourceNamed:@"anime_19"],
        [IRHelper imageInResourceNamed:@"anime_20"]
                                          ];
    [_animatingImageView startAnimating];
    [UIView animateWithDuration:0.3
                     animations:^{
        _fullscreenBackgroundView.alpha = 0.2;
        _animatingImageView.alpha       = 1.;
    }];

    // setup player

    _morseMessage = [_keys morseStringRepresentation];
    LOG(@"morseMessage: %@", _morseMessage);

    // fire key value observer
    [self observeValueForKeyPath:@"operationCount"
                        ofObject:nil
                          change:@{ NSKeyValueChangeNewKey: @0 }
                         context:nil];
}

- (void)stopPlaying {
    LOG_CURRENT_METHOD;

    [_doorWaiter cancel];

    [_player setSuspended:YES];
    [_player cancelAllOperations];
}

- (void)startWaitingForDoor {
    LOG_CURRENT_METHOD;

    if (_doorWaiter) {
        [_doorWaiter cancel];
    }
    __weak IRMorsePlayerViewController *_self = self;
    _doorWaiter = [IRHTTPClient waitForDoorWithDeviceID:_keys.deviceid completion:^(NSHTTPURLResponse *res, id object, NSError *error) {
        LOG(@"res: %@, error: %@", res, error);

        [_self stopPlaying];

        if (error) {
            return;
        }

        IRPeripheral *p = [[IRKit sharedInstance].peripherals savePeripheralWithName:object[ @"hostname" ]
                                                                            deviceid:_self.keys.deviceid];

        [_self.delegate morsePlayerViewController:_self
                                didFinishWithInfo:@{
             IRViewControllerResultType: IRViewControllerResultTypeDone,
             IRViewControllerResultPeripheral: p
         }];
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    LOG(@"keyPath: %@", keyPath);

    if ([keyPath isEqualToString:@"operationCount"]) {
        NSObject *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (newValue &&
            ([(NSNumber *)newValue unsignedIntegerValue] == 0))
        {
            [_player addOperation:[IRMorsePlayerOperation playMorseFromString:_morseMessage
                                                                withWordSpeed:[NSNumber numberWithInt:MORSE_WPM]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate morsePlayerViewControllerDidStartPlaying:self];
            });
        }
    }
}

#pragma mark - UI events

- (void)updateStartButtonViewWithVolume:(float)volume {
    LOG(@"volume: %f", volume);

    if (!_keys.keysAreSet) {
        // only show "Start" button after we have keys
        return;
    }

    if (!_shownStartButtonView && (volume == 1.0)) {
        _shownStartButtonView = YES;
        _startButtonBox.hidden = NO;
        CGRect original = _startButtonBox.frame;
        CGRect frame = _startButtonBox.frame;
        frame.origin.y += 70;
        _startButtonBox.frame = frame;
        [UIView animateWithDuration:0.3
                         animations:^{
            _startButtonBox.frame = original;
        }];
        [[[UIAlertView alloc] initWithTitle:IRLocalizedString(@"Shhh!", @"alertview title before pressing start button in morseviewcontroller")
                                    message:IRLocalizedString(@"Turn off your TV, audio devices, be quiet and press Start!", @"alertview message before pressing start button in morseviewcontroller")
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)morseNotWorkingButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;

    IRWifiAdhocViewController *c = [[IRWifiAdhocViewController alloc] initWithNibName:@"IRWifiAdhocViewController" bundle:[IRHelper resources]];
    c.keys = _keys;
    c.delegate = _delegate;
    [self.navigationController pushViewController:c animated:YES];
}

- (IBAction)startButtonPressed:(id)sender {
    LOG_CURRENT_METHOD;

    [self startPlaying];
    [self startWaitingForDoor];
}

@end
