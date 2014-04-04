#import "Log.h"
#import "IRPeripherals.h"
#import "IRPersistentStore.h"
#import "IRHelper.h"
#import "IRConst.h"
#import "IRHTTPClient.h"

@interface IRPeripherals ()

// NSNetService.hostName => IRPeripheral
@property (nonatomic) NSMutableDictionary *irperipheralForName;

@end

@implementation IRPeripherals

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    [self load];

    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG(@"index: %d", index);

    NSArray *keys = [_irperipheralForName keysSortedByValueUsingSelector: @selector(compareByFirstFoundDate:)];
    NSString *key = [keys objectAtIndex: index];
    return _irperipheralForName[key];
}

- (IRPeripheral *)peripheralWithName:(NSString *)name {
    LOG_CURRENT_METHOD;
    if (!name) {
        return nil;
    }
    return _irperipheralForName[name.lowercaseString];
}

- (void)save {
    LOG_CURRENT_METHOD;

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: _irperipheralForName];
    [IRPersistentStore storeObject: data
                            forKey: @"peripherals"];
    [IRPersistentStore synchronize];
}

- (NSUInteger)countOfReadyPeripherals {
    LOG_CURRENT_METHOD;
    return [[[_irperipheralForName allValues] filteredArrayUsingPredicate: [NSPredicate predicateWithBlock:^BOOL (id evaluatedObject, NSDictionary *bindings) {
                return [(IRPeripheral *)evaluatedObject hasDeviceID];
            }]
            ] count];
}

- (BOOL)isKnownName:(NSString *)hostname {
    LOG(@"hostname: %@", hostname);
    return _irperipheralForName[ hostname.lowercaseString ] ? YES : NO;
}

- (IRPeripheral *)registerPeripheralWithName:(NSString *)hostname {
    LOG(@"hostname: %@", hostname);
    IRPeripheral *peripheral = [[IRPeripheral alloc] init];
    peripheral.hostname       = hostname;
    peripheral.customizedName = hostname;
    [self addPeripheralsObject: peripheral];
    return peripheral;
}

- (IRPeripheral *)savePeripheralWithName:(NSString *)hostname deviceid:(NSString *)deviceid {
    LOG(@"hostname: %@ deviceid: %@", hostname, deviceid);

    IRPeripheral *p = [self peripheralWithName: hostname];
    if (!p) {
        p = [self registerPeripheralWithName: hostname];
    }
    p.deviceid = deviceid;
    [self save];
    [p getModelNameAndVersionWithCompletion:^{
        [self save];
    }];
    return p;
}

#pragma mark - Private methods

- (void)load {
    LOG_CURRENT_METHOD;

    NSData *data = [IRPersistentStore objectForKey: @"peripherals"];

    _irperipheralForName = data ? [[NSKeyedUnarchiver unarchiveObjectWithData: data] mutableCopy]
                           : nil;
    if (!_irperipheralForName) {
        _irperipheralForName = @{}.mutableCopy;
    }

    LOG(@"_irperipheralForName: %@", _irperipheralForName);
}

#pragma mark - Key Value Coding - Mutable Unordered Accessors

- (NSArray *)peripherals {
    LOG_CURRENT_METHOD;

    return [_irperipheralForName allValues];
}

- (NSUInteger)countOfPeripherals {
    LOG_CURRENT_METHOD;

    return _irperipheralForName.count;
}

- (NSEnumerator *)enumeratorOfPeripherals {
    LOG_CURRENT_METHOD;

    return [_irperipheralForName.allValues sortedArrayUsingSelector: @selector(compareByFirstFoundDate:)].objectEnumerator;
}

- (IRPeripheral *)memberOfPeripherals:(IRPeripheral *)object {
    NSString *lowercased = object.hostname.lowercaseString;

    for (IRPeripheral *p in self.peripherals) {
        if ([p.hostname.lowercaseString isEqualToString: lowercased]) {
            return p;
        }
    }
    return nil;
}

// -add<Key>Object:
- (void)addPeripheralsObject:(IRPeripheral *)peripheral {
    LOG(@"peripheral: %@", peripheral);

    if (!peripheral.hostname) {
        // can't add a peripheral without a name
        return;
    }

    _irperipheralForName[peripheral.hostname.lowercaseString] = peripheral;
}

- (void)removePeripheralsObject:(IRPeripheral *)peripheral {
    LOG(@"peripheral: %@", peripheral);

    [_irperipheralForName removeObjectForKey: peripheral.hostname.lowercaseString];
}

@end
