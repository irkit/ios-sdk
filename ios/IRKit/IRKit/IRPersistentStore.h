#import <Foundation/Foundation.h>

@interface IRPersistentStore : NSObject

+ (void) storeObject:(id)object forKey:(NSString *)defaultName;
+ (id) objectForKey: (NSString*) key;
+ (void) synchronize;

@end
