#import "Log.h"
#import "IRPeripherals.h"
#import "IRPersistentStore.h"
#import "IRHelper.h"
#import "IRConst.h"
#import "IRPeripheralCell.h"

@interface IRPeripherals ()

// NSNetService.hostName => IRPeripheral
@property (nonatomic) NSMutableDictionary* irperipheralForName;

@end

@implementation IRPeripherals

- (instancetype) init {
    self = [super init];
    if (! self) { return nil; }

    _irperipheralForName = @{}.mutableCopy;

    return self;
}

- (id)objectAtIndex:(NSUInteger)index {
    LOG( @"index: %d", index);

    NSArray* keys = [_irperipheralForName keysSortedByValueUsingSelector:@selector(compareByFirstFoundDate:)];
    NSString* key = [keys objectAtIndex: index];
    return _irperipheralForName[key];
}

// returns NSArray of CFUUIDs
- (NSArray*) knownPeripheralUUIDs {
    LOG_CURRENT_METHOD;
    return [IRHelper mapObjects:[_irperipheralForName allKeys]
                     usingBlock:(id)^(id obj, NSUInteger idx) {
                         return (__bridge_transfer id)(CFUUIDCreateFromString(NULL, (CFStringRef)obj));
                     }];
}

- (IRPeripheral*)IRPeripheralForName: (NSString*)name {
    LOG_CURRENT_METHOD;
    if ( ! name ) {
        return nil;
    }
    return _irperipheralForName[name];
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
            return [(IRPeripheral*)evaluatedObject isReady];
        }]
    ] count];
}

- (BOOL) isKnownName: (NSString*) hostname {
    LOG( @"hostname: %@", hostname );
    return _irperipheralForName[ hostname ] ? YES : NO;
}

- (IRPeripheral*)registerPeripheralWithName: (NSString*)hostname {
    LOG( @"hostname: %@", hostname );
    IRPeripheral *peripheral = [[IRPeripheral alloc] init];
    peripheral.name = hostname;
    _irperipheralForName[ hostname ] = peripheral;
    [self save];
    return peripheral;
}

#pragma mark - Private methods

- (void) load {
    LOG_CURRENT_METHOD;

    NSData* data = [IRPersistentStore objectForKey: @"peripherals"];

    _irperipheralForName = data ? (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data]
                                : nil;
    if ( ! _irperipheralForName ) {
        _irperipheralForName = [[NSMutableDictionary alloc] init];
    }

    LOG( @"_irperipheralForUUID: %@", _irperipheralForName );
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

//// -add<Key>Object:
//- (void)addPeripheralsObject:(CBPeripheral*) peripheral {
//    LOG( @"peripheral: %@", peripheral );
//
//    //    if ( ! peripheral.UUID || ! peripheral.name ) {
//    if ( ! peripheral.UUID ) {
//        // just to retain while 1st connect attempt
//        [_unknownPeripherals addObject:peripheral];
//        return;
//    }
//    // we got it's UUID, so don't need to retain peripheral in _unknownPeripherals anymore, we'll retain it in _irperipheralForUUID
//    [_unknownPeripherals removeObject:peripheral];
//
//    NSString *uuidKey = [IRHelper stringFromCFUUID:peripheral.UUID];
//
//    IRPeripheral *p = _irperipheralForUUID[uuidKey];
//    if (p) {
//        // found known but disconnected peripheral
//        [p setPeripheral: peripheral];
//        peripheral.delegate = p;
//    }
//    else {
//        p                   = [[IRPeripheral alloc] init];
//        [p setManager: _manager];
//        [p setPeripheral: peripheral];
//        p.customizedName    = peripheral.name; // defaults to original name
//        peripheral.delegate = p;
//        _irperipheralForUUID[uuidKey] = p;
//        [self save];
//    }
//}
//
//- (void)removePeripheralsObject: (CBPeripheral*) peripheral {
//    LOG( @"peripheral: %@", peripheral );
//
//    if ( ! peripheral.UUID ) {
//        [_unknownPeripherals removeObject:peripheral];
//        return;
//    }
//    NSString *uuidKey = [IRHelper stringFromCFUUID:peripheral.UUID];
//    [_irperipheralForUUID removeObjectForKey:uuidKey];
//}

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
