//
//  IRMorsePlayerOperation.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/10/08.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "Log.h"
#import "IRMorsePlayerOperation.h"
@import AVFoundation;

@interface IRMorsePlayerOperation ()

@property BOOL isExecuting;
@property BOOL isFinished;

@property (nonatomic) NSString *string;
@property (nonatomic) NSNumber *wpm;
@property (nonatomic) NSMutableArray *sequence; // array of 0:off 1:on
@property (nonatomic) int nextIndex;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) AVAudioPlayer *player;

@end

@implementation IRMorsePlayerOperation

static NSDictionary *asciiToMorse;

+ (void) load {
    LOG_CURRENT_METHOD;
    // 0: short
    // 1: long
    asciiToMorse = @{
                     @"A": @"01",
                     @"B": @"1000",
                     @"C": @"1010",
                     @"D": @"100",
                     @"E": @"0",
                     @"F": @"0010",
                     @"G": @"110",
                     @"H": @"0000",
                     @"I": @"00",
                     @"J": @"0111",
                     @"K": @"101",
                     @"L": @"0100",
                     @"M": @"11",
                     @"N": @"10",
                     @"O": @"111",
                     @"P": @"0110",
                     @"Q": @"1101",
                     @"R": @"010",
                     @"S": @"000",
                     @"T": @"1",
                     @"U": @"001",
                     @"V": @"0001",
                     @"W": @"011",
                     @"X": @"1001",
                     @"Y": @"1011",
                     @"Z": @"1100",
                     @"0": @"11111",
                     @"1": @"01111",
                     @"2": @"00111",
                     @"3": @"00011",
                     @"4": @"00001",
                     @"5": @"00000",
                     @"6": @"10000",
                     @"7": @"11000",
                     @"8": @"11100",
                     @"9": @"11110",
                     @".": @"010101",
                     @",": @"110011",
                     @"?": @"001100",
                     @"'": @"011110",
                     @"!": @"101011",
                     @"/": @"10010",
                     @"(": @"10110",
                     @")": @"101101",
                     @"&": @"01000",
                     @":": @"111000",
                     @";": @"101010",
                     @"=": @"10001",
                     @"+": @"01010",
                     @"-": @"100001",
                     @"_": @"001101",
                     @"\"":@"010010",
                     @"$": @"0001001",
                     @"@": @"011010"
    };
}

- (void) start {
    LOG_CURRENT_METHOD;

    self.isExecuting = YES;
    self.isFinished  = NO;

    [self parseAsciiStringIntoSequence];

    _player = [self newPlayer];

    _timer = [self newTimer];
    [[NSRunLoop currentRunLoop] addTimer:_timer
                                 forMode:NSDefaultRunLoopMode];

    [self timerFired:nil];

    do {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    } while (!_isFinished);
}

+ (IRMorsePlayerOperation*) playMorseFromString:(NSString*)input
                                  withWordSpeed:(NSNumber*)wpm {
    LOG_CURRENT_METHOD;

    // validation
    if ( ! input ) {
        return nil;
    }
    for (int i=0; i<input.length; i++) {
        unichar character = [input characterAtIndex:i];
        if (! [self isCharacterAllowed:character]) {
            LOG( @"character: %c is not allowed!!", character );
            return nil;
        }
    }
    IRMorsePlayerOperation *op = [[IRMorsePlayerOperation alloc] init];
    op.string = input;
    op.wpm = wpm;

    return op;
}

#pragma mark - Private

+ (bool) isCharacterAllowed: (unichar) character {
    return !! asciiToMorse[ [[NSString stringWithFormat:@"%c", character] uppercaseString] ];
}

- (void) parseAsciiStringIntoSequence {
    _sequence = @[].mutableCopy;

    for (int i=0; i<_string.length; i++) {
        unichar character = [_string characterAtIndex:i];
        NSString *morseCode = asciiToMorse[ [[NSString stringWithFormat:@"%c",character] uppercaseString]];
        for (int j=0; j<morseCode.length; j++) {
            unichar shortOrLong = [morseCode characterAtIndex:j];
            if ( shortOrLong == '0' ) {
                // short
                [_sequence addObject:@1]; // 1: on
            }
            else if (shortOrLong == '1' ) {
                // long
                [_sequence addObjectsFromArray:@[ @1, @1, @1 ]];
            }

            // symbol space
            [_sequence addObject:@0]; // 0: off
        }
        // letter space
        [_sequence addObjectsFromArray:@[ @0, @0 ]];
    }
    // word space
    [_sequence addObjectsFromArray:@[ @0, @0, @0, @0 ]];

    _nextIndex = 0;
}

- (NSTimer*) newTimer {
    LOG_CURRENT_METHOD;

    // see http://en.wikipedia.org/wiki/Morse_code
    // unit time, or dot duration, in milliseconds
    float unitTime = 1200 / _wpm.floatValue;
    NSTimer *timer = [NSTimer timerWithTimeInterval:unitTime / 1000.
                                             target:self
                                           selector:@selector(timerFired:)
                                           userInfo:nil
                                            repeats:YES];
    return timer;
}

- (AVAudioPlayer*) newPlayer {
    NSBundle *main = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];
    NSString *path = [resources pathForResource:@"sin_1000Hz_0dB_1s"
                                         ofType:@"aiff"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]
                                                     error:nil];
    player.numberOfLoops = -1; // infinite
    [player prepareToPlay];
    return player;
}

- (void) timerFired: (NSTimer*) timer {
    // LOG_CURRENT_METHOD;

    NSNumber *onOrOff = _sequence[ _nextIndex ];
    if (onOrOff == @0) {
        // off
        LOG( @"off" );
        [_player pause];
        _player.currentTime = 0.1;
    }
    else {
        // on
        LOG( @"on" );
        if ( ! _player.playing ) {
            [_player play];
        }
    }

    _nextIndex ++;
    if (_nextIndex == _sequence.count) {
        [self finish];
    }
}

- (void) finish {
    LOG_CURRENT_METHOD;

    [_player stop];
    [_timer invalidate];

    self.isExecuting = NO;
    self.isFinished  = YES;
}

#pragma mark - KVO

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    if ([key isEqualToString:@"isExecuting"] || [key isEqualToString:@"isFinished"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

- (BOOL)isConcurrent
{
    return NO;
}

@end
