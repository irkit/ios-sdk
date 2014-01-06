#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IRPeripheral.h"

@interface IRPeripherals : NSObject<UITableViewDelegate,UITableViewDataSource>

- (id)objectAtIndex:(NSUInteger)index;
- (IRPeripheral*)peripheralWithName: (NSString*)name;
- (void) save;
- (NSUInteger) countOfReadyPeripherals;
- (BOOL) isKnownName: (NSString*)hostname;
- (IRPeripheral*)registerPeripheralWithName: (NSString*)hostname;
- (IRPeripheral*)savePeripheralWithName:(NSString*)hostname deviceid:(NSString*)deviceid;

#pragma mark - Key Value Coding - Mutable Unordered Accessors

- (NSArray*) peripherals;
- (NSUInteger) countOfPeripherals;
- (NSEnumerator *)enumeratorOfPeripherals;
- (void)addPeripheralsObject:(IRPeripheral*) peripheral;
- (void)removePeripheralsObject: (IRPeripheral*) peripheral;
- (IRPeripheral*)memberOfPeripherals:(IRPeripheral *)object;

@end
