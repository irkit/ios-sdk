//
//  IRPeripheral.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRSignal : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *data;

@end
