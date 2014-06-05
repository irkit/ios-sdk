#import <Foundation/Foundation.h>
#import "IRPersistentStore.h"

@interface IRUserDefaultsStore : NSObject<IRPersistentStore>

- (void)storeObject:(id)object forKey:(NSString *)key;
- (void)storePeripherals:(NSDictionary*)object;
- (id)objectForKey:(NSString *)key;
- (NSDictionary*)loadPeripherals;
- (void)synchronize;

@end
