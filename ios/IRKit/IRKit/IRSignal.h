//
//  IRPeripheral.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/20.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRPeripheral.h"

@interface IRSignal : NSObject

- (id)initWithData: (NSData*) newData;
- (id) initWithDictionary: (NSDictionary*) dictionary;
- (NSDictionary*)asDictionary;
- (NSComparisonResult) compareByReceivedDate: (IRSignal*) otherSignal;
- (NSString*) uniqueID;
- (void)sendWithCompletion: (void (^)(NSError* error))block;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSArray *data;
@property (nonatomic) NSUInteger frequency; // kHz
@property (nonatomic) NSDate *receivedDate;
@property (nonatomic) IRPeripheral *peripheral;

@property (nonatomic) NSString* peripheralUUID;

@end
