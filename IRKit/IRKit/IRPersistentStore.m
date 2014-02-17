#import "Log.h"
#import "IRPersistentStore.h"

#define IR_NSUSERDEFAULTS_PREFIX @"ir"

@implementation IRPersistentStore

+ (void)storeObject:(id)object forKey:(NSString *)key {
    LOG_CURRENT_METHOD;

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:object
          forKey:[NSString stringWithFormat:@"%@:%@",
                  IR_NSUSERDEFAULTS_PREFIX, key]];
}

+ (id)objectForKey:(NSString *)key {
    LOG_CURRENT_METHOD;

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    return [d objectForKey:[NSString stringWithFormat:@"%@:%@",
                            IR_NSUSERDEFAULTS_PREFIX, key]];
}

+ (void)synchronize {
    LOG_CURRENT_METHOD;
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
