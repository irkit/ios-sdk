#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IRPeripheral.h"

@interface IRPeripherals : NSObject<UITableViewDelegate,UITableViewDataSource>

//- (id)initWithManager: (CBCentralManager*) manager;
- (id)objectAtIndex:(NSUInteger)index;
- (NSArray*) knownPeripheralUUIDs;
//- (IRPeripheral*)IRPeripheralForPeripheral: (CBPeripheral*)peripheral;
//- (IRPeripheral*)IRPeripheralForUUID: (NSString*)uuid;
- (void) save;
- (NSUInteger) countOfReadyPeripherals;
- (BOOL) isKnownName: (NSString*)hostname;
- (IRPeripheral*)registerPeripheralWithName: (NSString*)hostname;

#pragma mark - Key Value Coding - Mutable Unordered Accessors

- (NSArray*) peripherals;
- (NSUInteger) countOfPeripherals;
- (NSEnumerator *)enumeratorOfPeripherals;
//- (CBPeripheral*)memberOfPeripherals:(CBPeripheral *)object;
//- (void)addPeripheralsObject:(CBPeripheral*) peripheral;
//- (void)removePeripheralsObject: (CBPeripheral*) peripheral;

@end
