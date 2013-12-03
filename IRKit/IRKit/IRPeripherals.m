#import "Log.h"
#import "IRPeripherals.h"
#import "IRPersistentStore.h"
#import "IRHelper.h"
#import "IRConst.h"
#import "IRPeripheralCell.h"
#import "IRHTTPClient.h"

@interface IRPeripherals ()

// NSNetService.hostName => IRPeripheral
@property (nonatomic) NSMutableDictionary* irperipheralForName;

@end

@implementation IRPeripherals

- (instancetype) init {
    self = [super init];
    if (! self) { return nil; }

    [self load];
    [self check];

    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);

    NSArray* keys = [_irperipheralForName keysSortedByValueUsingSelector:@selector(compareByFirstFoundDate:)];
    NSString* key = [keys objectAtIndex: index];
    return _irperipheralForName[key];
}

- (IRPeripheral*)IRPeripheralForName: (NSString*)name {
    LOG_CURRENT_METHOD;
    if ( ! name ) {
        return nil;
    }
    return _irperipheralForName[name.lowercaseString];
}

- (void) save {
    LOG_CURRENT_METHOD;

    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:_irperipheralForName];
    [IRPersistentStore storeObject:data
                            forKey:@"peripherals"];
    [IRPersistentStore synchronize];
}

- (NSUInteger) countOfReadyPeripherals {
    LOG_CURRENT_METHOD;
    return [[[_irperipheralForName allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [(IRPeripheral*)evaluatedObject hasKey];
        }]
    ] count];
}

- (BOOL) isKnownName: (NSString*) hostname {
    LOG( @"hostname: %@", hostname );
    return _irperipheralForName[ hostname.lowercaseString ] ? YES : NO;
}

- (IRPeripheral*)registerPeripheralWithName: (NSString*)hostname {
    LOG( @"hostname: %@", hostname );
    IRPeripheral *peripheral = [[IRPeripheral alloc] init];
    peripheral.name = hostname;
    [self addPeripheralsObject:peripheral];
    return peripheral;
}

- (void)waitForSignalWithCompletion:(void (^)(IRSignal*))completion {
    LOG_CURRENT_METHOD;
    
}

#pragma mark - Private methods

- (void) load {
    LOG_CURRENT_METHOD;

    NSData* data = [IRPersistentStore objectForKey: @"peripherals"];

    _irperipheralForName = data ? [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy]
                                : nil;
    if ( ! _irperipheralForName ) {
        _irperipheralForName = @{}.mutableCopy;
    }

    LOG( @"_irperipheralForName: %@", _irperipheralForName );
}

- (void) check {
    LOG_CURRENT_METHOD;

    for (IRPeripheral *p in self.peripherals) {
        if (! [p hasKey]) {
            [p getKeyWithCompletion:^{
                [self save];
            }];
        }
    }
}

#pragma mark - Key Value Coding - Mutable Unordered Accessors

- (NSArray*) peripherals {
    LOG_CURRENT_METHOD;

    return [_irperipheralForName allValues];
}

- (NSUInteger) countOfPeripherals {
    LOG_CURRENT_METHOD;

    return _irperipheralForName.count;
}

- (NSEnumerator *)enumeratorOfPeripherals {
    LOG_CURRENT_METHOD;

    return [_irperipheralForName.allValues sortedArrayUsingSelector:@selector(compareByFirstFoundDate:)].objectEnumerator;
}

- (IRPeripheral*)memberOfPeripherals:(IRPeripheral *)object {
    NSString *lowercased = object.name.lowercaseString;
    for (IRPeripheral *p in self.peripherals) {
        if ([p.name.lowercaseString isEqualToString:lowercased]) {
            return p;
        }
    }
    return nil;
}

// -add<Key>Object:
- (void)addPeripheralsObject:(IRPeripheral*) peripheral {
    LOG( @"peripheral: %@", peripheral );

    if ( ! peripheral.name ) {
        // can't add a peripheral without a name
        return;
    }

    _irperipheralForName[peripheral.name.lowercaseString] = peripheral;
}

- (void)removePeripheralsObject: (IRPeripheral*) peripheral {
    LOG( @"peripheral: %@", peripheral );

    [_irperipheralForName removeObjectForKey:peripheral.name.lowercaseString];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG( @"indexPath.row: %d", indexPath.row);

    IRPeripheralCell *cell = (IRPeripheralCell*)[tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierPeripheral];
    if (cell == nil) {
        NSBundle *main = [NSBundle mainBundle];
        NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                      ofType:@"bundle"]];
        [tableView registerNib:[UINib nibWithNibName:@"IRPeripheralCell" bundle:resources]
        forCellReuseIdentifier:IRKitCellIdentifierPeripheral];

        cell = [tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierPeripheral];
    }
    cell.peripheral = [self objectAtIndex: indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    return self.countOfPeripherals;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    return [IRPeripheralCell height];
}

@end
