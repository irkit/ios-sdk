//
//  IRSignalSequence.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2014/02/20.
//
//

#import <Foundation/Foundation.h>
#import "IRSignal.h"

@interface IRSignalSequence : NSObject<IRSendable>

- (instancetype)initWithSignals:(NSArray*)signals andIntervals:(NSArray*)intervals;

@end
