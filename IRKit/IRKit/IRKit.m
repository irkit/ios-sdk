#import "Log.h"
#import "IRKit.h"
#import "IRFunc.h" // private
#import "IRPeripheral.h"
#import "IRHelper.h"
#import "IRViewCustomizer.h"

#import "IRWifiEditViewController.h"
#import "IREditCell.h"

@interface IRKit ()

@property (nonatomic) id terminateObserver;
@property (nonatomic) id becomeActiveObserver;
@property (nonatomic) id enterBackgroundObserver;

@end

@implementation IRKit

+ (instancetype) sharedInstance {
    static IRKit* instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [[IRKit alloc] init];
    });
    return instance;
}

- (instancetype)init {
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
                                                                          }];
    _enterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                                 object:nil
                                                                                  queue:[NSOperationQueue mainQueue]
                                                                             usingBlock:^(NSNotification *note) {
                                                                                 LOG( @"entered background" );
                                                                             }];
    [IRViewCustomizer sharedInstance]; // init

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

#pragma mark - Private

@end
