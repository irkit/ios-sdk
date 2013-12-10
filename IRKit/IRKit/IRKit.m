#import "Log.h"
#import "IRKit.h"
#import "IRFunc.h" // private
#import "IRPeripheral.h"
#import "IRHelper.h"
#import "IRViewCustomizer.h"
#import "IRPersistentStore.h"
#import "IRHTTPClient.h"

@interface IRKit ()

@property (nonatomic) id terminateObserver;
@property (nonatomic) id becomeActiveObserver;
@property (nonatomic) id enterBackgroundObserver;
@property (nonatomic, copy) NSString *clientkey;

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
                                                                              [self registerIfNot];
                                                                          }];
    _enterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                                 object:nil
                                                                                  queue:[NSOperationQueue mainQueue]
                                                                             usingBlock:^(NSNotification *note) {
                                                                                 LOG( @"entered background" );
                                                                             }];
    [IRViewCustomizer sharedInstance]; // init

    _clientkey = [IRPersistentStore objectForKey:@"clientkey"];
    [self registerIfNot];

    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:_terminateObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_becomeActiveObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_enterBackgroundObserver];
}

- (void) registerIfNot {
    LOG_CURRENT_METHOD;

    if (! _clientkey) {
        [IRHTTPClient registerWithCompletion:^(NSHTTPURLResponse *res, NSString *clientkey, NSError *error) {
            if (clientkey) {
                _clientkey = clientkey;
                [IRPersistentStore storeObject:_clientkey forKey:@"clientkey"];
                LOG( @"successfully registered! clientkey: %@", clientkey );
            }
        }];
    }
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
