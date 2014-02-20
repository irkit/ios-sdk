//
//  IRSignalSequence.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/02/20.
//
//

#import <Foundation/Foundation.h>
#import "IRSignal.h"

@interface IRSignalSequence : NSObject<IRSendable,NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSDictionary *custom;

- (instancetype)initWithSignals:(NSArray*)signals andIntervals:(NSArray*)intervals;

@end
