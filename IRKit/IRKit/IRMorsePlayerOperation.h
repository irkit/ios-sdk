//
//  IRMorsePlayerOperation.h
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/10/08.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Type of audio sample produced by an AudioProducer
typedef SInt16 Sample;

@interface IRMorsePlayerOperation : NSOperation

+ (IRMorsePlayerOperation*) playMorseFromString:(NSString*)input
                                  withWordSpeed:(NSNumber*)wpm;

@end

/// Simple AudioProducer that produces a sine wave
@interface SineWave : NSObject

@property (nonatomic, setter=setFrequency:)  float  frequency;
@property (nonatomic, setter=setPeak:)       Sample peak;
@property (nonatomic, setter=setSampleRate:) float  sampleRate;

/// Fills a buffer with "size" samples.
/// The buffer should be filled in with interleaved stereo samples.
- (void) produceSamples:(Sample *)audioBuffer size:(size_t)size;

@end
