//
//  ONSignals.h
//  One
//
//  Created by Masakazu Ohtsuka on 2013/07/26.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IRKit/IRKit.h>

@interface ONSignals : NSObject

@property (nonatomic) IRSignals *signals;
@property (nonatomic) BOOL updatedInBackground;

+ (instancetype) sharedInstance;
- (void)save;
- (void)sendSequentiallyWithCompletion:(void (^)(NSError *error))completion;

@end
