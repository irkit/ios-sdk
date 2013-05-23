//
//  IRPersistentStore.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/23.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRPersistentStore : NSObject

+ (void) storeObject:(id)object forKey:(NSString *)defaultName;
+ (id) objectForKey: (NSString*) key;
+ (void) synchronize;

@end
