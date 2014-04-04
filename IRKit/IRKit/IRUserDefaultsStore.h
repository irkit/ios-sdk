#import <Foundation/Foundation.h>
#import "IRPersistentStore.h"

@interface IRUserDefaultsStore : NSObject<IRPersistentStore>

- (void)storeObject:(id)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (void)synchronize;

@end
