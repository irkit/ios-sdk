//
//  IRKit+Internal.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/04/04.
//
//

#import "IRKit.h"

/// publicize some properties for internal access
@interface IRKit (Internal)

@property (nonatomic, copy) NSString *apikey;
@property (nonatomic, copy) NSString *clientkey;
@property (nonatomic) id<IRPersistentStore> store;

@end
