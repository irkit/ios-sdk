#import "Log.h"
#import "IRKit.h"
#import "IRFunc.h" // private
#import "IRPeripheral.h"
#import "IRHelper.h"
#import "IRViewCustomizer.h"

static BOOL useCustomizedStyle;

@interface IRKit ()

@property (nonatomic) CBCentralManager* manager;
@property (nonatomic) BOOL isScanning;
@property (nonatomic) id terminateObserver;
@property (nonatomic) id becomeActiveObserver;
@property (nonatomic) id enterBackgroundObserver;

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

    _manager = [[CBCentralManager alloc] initWithDelegate:self
                                                    queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) ];

    _peripherals = [[IRPeripherals alloc] initWithManager:_manager];
    _isScanning  = NO;

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
                                                                              [_self retrieveKnownPeripherals];
                                                                          }];
    _enterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                                                 object:nil
                                                                                  queue:[NSOperationQueue mainQueue]
                                                                             usingBlock:^(NSNotification *note) {
                                                                                 LOG( @"entered background" );
                                                                                 if (_self.retainConnectionInBackground) {
                                                                                     return;
                                                                                 }
                                                                                 for (IRPeripheral* p in _self.peripherals.peripherals) {
                                                                                     [p disconnect];
                                                                                 }
                                                                             }];
    _retainConnectionInBackground = NO;
    [IRViewCustomizer sharedInstance]; // init
    [self retrieveKnownPeripherals];

    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [[NSNotificationCenter defaultCenter] removeObserver:_terminateObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_becomeActiveObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_enterBackgroundObserver];
}

- (void) save {
    LOG_CURRENT_METHOD;
    [_peripherals save];
}

- (NSUInteger) numberOfAuthenticatedPeripherals {
    LOG_CURRENT_METHOD;
    return _peripherals.countOfAuthenticatedPeripherals;
}

- (NSUInteger) numberOfPeripherals {
    LOG_CURRENT_METHOD;
    return _peripherals.countOfPeripherals;
}

- (void) startScan {
    LOG_CURRENT_METHOD;
    _isScanning = YES;

    if (_manager.state == CBCentralManagerStatePoweredOn) {
        // we want duplicates:
        // peripheral updates receivedCount in adv packet when receiving IR data
        [_manager scanForPeripheralsWithServices:@[ IRKIT_SERVICE_UUID ]
                                         options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES
         }];
    }
}

- (void) stopScan {
    LOG_CURRENT_METHOD;
    _isScanning = NO;
    [_manager stopScan];
}

#pragma mark - Private

- (void) retrieveKnownPeripherals {
    LOG_CURRENT_METHOD;

    NSArray *knownPeripherals = [_peripherals knownPeripheralUUIDs];
    if ([knownPeripherals count]) {
        LOG( @"retrieve: %@", knownPeripherals );
        [_manager retrievePeripherals: knownPeripherals];
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    LOG( @"peripheral: %@ advertisementData: %@ RSSI: %@", peripheral, advertisementData, RSSI );

    [_peripherals addPeripheralsObject:peripheral]; // retain
    IRPeripheral* p = [_peripherals IRPeripheralForPeripheral:peripheral];
    if (p) {
        [p didDiscoverWithAdvertisementData: advertisementData
                                       RSSI: RSSI];
    }
    else {
        // we don't know it's UUID, let's connect and figure it out
        [_manager connectPeripheral:peripheral
                            options:@{
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES
         }];
    }
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    LOG(@"peripheral: %@", peripheral);

}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 */
- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals {
    LOG( @"peripherals: %@", peripherals);

    for (CBPeripheral *peripheral in peripherals) {
        [_peripherals addPeripheralsObject:peripheral]; // retain
        IRPeripheral* p = [_peripherals IRPeripheralForPeripheral:peripheral];
        [p didRetrieve];
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    LOG( @"peripheral: %@, RSSI: %@", peripheral, peripheral.RSSI );

    // when a new peripheral is discovered,
    // we don't know it's UUID.
    // connect without an IRPeripheral
    // and get an IRPeripheral here
    [_peripherals addPeripheralsObject:peripheral];

    IRPeripheral *p = [_peripherals IRPeripheralForPeripheral:peripheral];
    [p didConnect];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    LOG( @"peripheral: %@ error: %@", peripheral, error);

    IRPeripheral *p = [_peripherals IRPeripheralForPeripheral:peripheral];
    [p didDisconnect];

    // hack
    // see http://stackoverflow.com/questions/9896562/what-exactly-can-corebluetooth-applications-do-whilst-in-the-background/17484051#17484051
    if (_retainConnectionInBackground) {
        [self stopScan];
        [self startScan];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    LOG( @"state: %@", NSStringFromCBCentralManagerState([central state]));

    if (_isScanning && (central.state == CBCentralManagerStatePoweredOn)) {
        [self startScan];
    }
}

@end
