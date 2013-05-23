//
//  IRPeripheral.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//
// IRPeripheral stores additional info related to CBPeripheral

#import <Foundation/Foundation.h>

@interface IRPeripheral : NSObject

@property(nonatomic, copy) NSString *customizedName;
@property(nonatomic, copy) NSNumber *isPaired;
@property(nonatomic, copy) NSDate   *foundDate;

- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral;

@end
