//
//  IRMorsePlayerOperation.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/10/08.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRMorsePlayerOperation : NSOperation

+ (IRMorsePlayerOperation*) playMorseFromString:(NSString*)input
                                  withWordSpeed:(NSNumber*)wpm;

@end
