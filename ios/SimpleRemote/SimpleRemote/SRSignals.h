//
//  SRSignals.h
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/07/26.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IRKit/IRKit.h>

@interface SRSignals : NSObject

@property (nonatomic) IRSignals *signals;
@property (nonatomic) BOOL updatedInBackground;

+ (instancetype) sharedInstance;
- (void)sendSequentially;

@end
