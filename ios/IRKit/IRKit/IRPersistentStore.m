//
//  IRPersistentStore.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRPersistentStore.h"

#define IR_NSUSERDEFAULTS_PREFIX @"ir"

@implementation IRPersistentStore

+ (void) storeObject:(id)object forKey:(NSString *)defaultName {
    LOG_CURRENT_METHOD;
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:object
          forKey:[NSString stringWithFormat:@"%@:%@",
                  IR_NSUSERDEFAULTS_PREFIX, defaultName]];
}

+ (id) objectForKey: (NSString*) key {
    LOG_CURRENT_METHOD;
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    return [d objectForKey: [NSString stringWithFormat: @"%@:%@",
                             IR_NSUSERDEFAULTS_PREFIX, key]];
}

+ (void) synchronize {
    LOG_CURRENT_METHOD;
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
