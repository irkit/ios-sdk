#import "Log.h"
#import "IRKit.h"
#import "IRFunc.h" // private
#import "IRPeripheral.h"
#import "IRHelper.h"
#import "IRViewCustomizer.h"

#import "IRWifiEditViewController.h"
#import "IREditCell.h"

static BOOL useCustomizedStyle;

@interface IRKit ()

//@property (nonatomic) CBCentralManager* manager;
@property (nonatomic) id terminateObserver;
@property (nonatomic) id becomeActiveObserver;
@property (nonatomic) id enterBackgroundObserver;
@property (nonatomic) NSTimer *stopSearchTimer;

// don't search for IRKit device after stopSearch was called (from IRNewPeripheralVC, mainly)
// cleared on enter background
// we don't want to see timing problems of which (POST /door response or Bonjour) is faster to detect online IRKit
// prioritize POST /door response, and stop searching Bonjour in IRNewPeripheralVC
@property (nonatomic) BOOL stopCalled;

@end

@implementation IRKit

+ (id) sharedInstance {
    static IRKit* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[IRKit alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (! self) { return nil; }

    _peripherals = [[IRPeripherals alloc] init];

    __weak IRKit *_self = self;
    _terminateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                                           object:nil
                                                                            queue:[NSOperationQueue mainQueue]
                                                                       usingBlock:^(NSNotification *note) {
                                                                           LOG( @"terminating" );
                                                                           [_self save];
                                                                       }];
    _becomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                              object:nil
                                                                               queue:[NSOperationQueue mainQueue]
                                                                          usingBlock:^(NSNotification *note) {
                                                                              LOG( @"became active" );
                                                                              // if opened in the middle of NewPeripheralVC
                                                                              // it might have called stopSearch
                                                                              if (! _stopCalled) {
                                                                                  [self startSearch];
                                                                              }
                                                                          }];
    _enterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                                 object:nil
                                                                                  queue:[NSOperationQueue mainQueue]
                                                                             usingBlock:^(NSNotification *note) {
                                                                                 LOG( @"entered background" );
                                                                                 _stopCalled = false;
                                                                             }];
    [IRViewCustomizer sharedInstance]; // init

    _stopCalled = false;
    [self startSearch];

    // temp
    [IRWifiEditViewController class];
    [IREditCell class];

    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[IRSearcher sharedInstance] stop];
    [[NSNotificationCenter defaultCenter] removeObserver:_terminateObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_becomeActiveObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_enterBackgroundObserver];
}

- (void) save {
    LOG_CURRENT_METHOD;
    [_peripherals save];
}

- (NSUInteger) countOfReadyPeripherals {
    LOG_CURRENT_METHOD;
    return _peripherals.countOfReadyPeripherals;
}

- (NSUInteger) numberOfPeripherals {
    LOG_CURRENT_METHOD;
    return _peripherals.countOfPeripherals;
}

// start searching for the first 30 seconds,
// if no new IRKit device found, stop then
- (void) startSearch {
    LOG_CURRENT_METHOD;
    [IRSearcher sharedInstance].delegate = self;
    [[IRSearcher sharedInstance] start];
    _stopSearchTimer = [NSTimer scheduledTimerWithTimeInterval:30.
                                                        target:self
                                                      selector:@selector(stopSearch)
                                                      userInfo:NULL
                                                       repeats:NO];
}

- (void) stopSearch {
    LOG_CURRENT_METHOD;
    _stopCalled = YES;
    [_stopSearchTimer invalidate];
    _stopSearchTimer = nil;

    [[IRSearcher sharedInstance] stop];
}

#pragma mark - Private

#pragma mark - IRSearcherDelegate

- (void)searcher:(IRSearcher *)searcher didResolveService:(NSNetService*)service {
    LOG( @"service: %@", service );
    NSString *shortname = [service.hostName componentsSeparatedByString:@"."][ 0 ];
    if ( ! [_peripherals isKnownName:shortname]) {
        IRPeripheral *p = [_peripherals registerPeripheralWithName:shortname];
        [_peripherals save];
        [p getKeyWithCompletion:^{
            [_peripherals save];
        }];
    }
}

@end
