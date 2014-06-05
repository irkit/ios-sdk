#import "Log.h"
#import "IRUserDefaultsStore.h"

#define IR_NSUSERDEFAULTS_PREFIX @"ir"

@implementation IRUserDefaultsStore

- (void)storeObject:(id)object forKey:(NSString *)key {
    LOG_CURRENT_METHOD;

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject: object
          forKey: [NSString stringWithFormat: @"%@:%@",
                   IR_NSUSERDEFAULTS_PREFIX, key]];
}

- (void)storePeripherals:(NSDictionary*)object {
    LOG_CURRENT_METHOD;

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: object];
    [self storeObject: data forKey: @"peripherals"];
}

- (id)objectForKey:(NSString *)key {
    LOG_CURRENT_METHOD;

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    return [d objectForKey: [NSString stringWithFormat: @"%@:%@",
                             IR_NSUSERDEFAULTS_PREFIX, key]];
}

- (NSDictionary*)loadPeripherals {
    NSData *data = [self objectForKey: @"peripherals"];
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData: data]
           : nil;
}

- (void)synchronize {
    LOG_CURRENT_METHOD;
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
