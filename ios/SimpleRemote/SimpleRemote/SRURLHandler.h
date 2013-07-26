//
//  SRURLHandler.h
//  SimpleRemote
//
//  Created by Masakazu Ohtsuka on 2013/07/26.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IRKit/IRKit.h>

@interface SRURLHandler : NSObject

+ (BOOL) canHandleOpenURL: (NSURL*)url;
+ (void) handleOpenURL: (NSURL*)url;
+ (NSArray*)signalsDictionariesFromURL:(NSURL*)url;
+ (IRSignals*)signalsFromURL:(NSURL*)url;

@end
