//
//  IRMorsePlayerOperation.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/10/08.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "Log.h"
#import "IRMorsePlayerOperation.h"
@import AudioToolbox;
@import AudioUnit;

#define OUTPUT_BUS          0
#define NUM_CHANNELS        2
#define SAMPLE_RATE         44100
#define ERROR_HERE(status) do {if (status) fprintf(stderr, "ERROR %d [%s:%u]\n", (int)status, __func__, __LINE__);}while(0);
#define LONGEST_CHARACTER_LENGTH 7 // $
#define SOUND_SILENCE      0
#define SOUND_SINE         1
#define SOUND_SINE_FADEOUT 2

@interface IRMorsePlayerOperation ()

@property BOOL isExecuting;
@property BOOL isFinished;

@property (nonatomic) NSString *string;
@property (nonatomic) NSNumber *wpm;
@property (nonatomic) SineWave *producer;

@end

@implementation IRMorsePlayerOperation {
    AudioComponentInstance audioUnit;
    uint8_t *_sequence;
    int _sequenceCount;
    int _nextIndex;
    int _remainingSamplesOfIndex;
    size_t _samplesPerUnit;
}

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
                     @"$": @"0001001", // longest
                     @"@": @"011010"
    };
}

- (void) start {
    LOG_CURRENT_METHOD;

    _producer = [[SineWave alloc] init];

    self.isExecuting = YES;
    self.isFinished  = NO;

    [self parseAsciiStringIntoSequence];

    [self preparePlayer];
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
    op.wpm = @5; // debugging

    return op;
}

#pragma mark - Private

+ (bool) isCharacterAllowed: (unichar) character {
    return !! asciiToMorse[ [[NSString stringWithFormat:@"%c", character] uppercaseString] ];
}

- (void) parseAsciiStringIntoSequence {
    // each character can be as long as
    // * 7 dah (dah = 3 dit)
    // * 7 symbol interval (symbol interval = 1 dit)
    // * 1 letter space (= 2 dit)
    // + word space (= 4 dit)
    _sequence = malloc(_string.length * (LONGEST_CHARACTER_LENGTH * 4 + 2) + 4);

    int sequenceIndex = 0;
    for (int i=0; i<_string.length; i++) {
        unichar character = [_string characterAtIndex:i];
        NSString *morseCode = asciiToMorse[ [[NSString stringWithFormat:@"%c",character] uppercaseString]];
        for (int j=0; j<morseCode.length; j++) {
            unichar shortOrLong = [morseCode characterAtIndex:j];
            if ( shortOrLong == '0' ) {
                // short
                _sequence[ sequenceIndex ++ ] = SOUND_SINE_FADEOUT;
            }
            else if (shortOrLong == '1' ) {
                // long
                _sequence[ sequenceIndex ++ ] = SOUND_SINE;
                _sequence[ sequenceIndex ++ ] = SOUND_SINE;
                _sequence[ sequenceIndex ++ ] = SOUND_SINE_FADEOUT;
            }

            // symbol space
            _sequence[ sequenceIndex ++ ] = SOUND_SILENCE;
        }
        // letter space
        _sequence[ sequenceIndex ++ ] = SOUND_SILENCE;
        _sequence[ sequenceIndex ++ ] = SOUND_SILENCE;
    }
    // word space
    _sequence[ sequenceIndex ++ ] = SOUND_SILENCE;
    _sequence[ sequenceIndex ++ ] = SOUND_SILENCE;
    _sequence[ sequenceIndex ++ ] = SOUND_SILENCE;
    _sequence[ sequenceIndex ++ ] = SOUND_SILENCE;

    _sequenceCount = sequenceIndex;
    _nextIndex = 0;
    // unit time, or dot duration, in milliseconds
    double unitTime = 1200. / _wpm.floatValue;
    _samplesPerUnit = (size_t)( (double)(SAMPLE_RATE) * unitTime / 1000. );
    _remainingSamplesOfIndex = _samplesPerUnit;
}

- (void) preparePlayer {
    LOG_CURRENT_METHOD;
    OSStatus status = noErr;

	AudioComponentDescription desc;
	desc.componentType          = kAudioUnitType_Output;
	desc.componentSubType       = kAudioUnitSubType_RemoteIO;
	desc.componentFlags         = 0;
	desc.componentFlagsMask     = 0;
	desc.componentManufacturer  = kAudioUnitManufacturer_Apple;

	AudioComponent outputComponent = AudioComponentFindNext(NULL, &desc);

	status = AudioComponentInstanceNew(outputComponent, &audioUnit);
    ERROR_HERE(status);

	UInt32 flag = 1;
	status = AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, OUTPUT_BUS, &flag, sizeof(flag));
    ERROR_HERE(status);

	AudioStreamBasicDescription audioFormat;
	audioFormat.mSampleRate         = SAMPLE_RATE;
	audioFormat.mFormatID           = kAudioFormatLinearPCM;
	audioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	audioFormat.mFramesPerPacket    = 1;
	audioFormat.mChannelsPerFrame   = NUM_CHANNELS;
	audioFormat.mBitsPerChannel     = 16;
	audioFormat.mBytesPerPacket     = 4;
	audioFormat.mBytesPerFrame      = 4;

	status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, OUTPUT_BUS, &audioFormat, sizeof(audioFormat));
    ERROR_HERE(status);

//    if (!status) {
//        status = AudioUnitAddRenderNotify(audioUnit, audioUnitCallback, (__bridge void *)self);
//    }

	AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc       = audioUnitCallback;
	callbackStruct.inputProcRefCon = (__bridge void *)(self);

    if (!status) {
        status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, OUTPUT_BUS, &callbackStruct, sizeof(callbackStruct));
        ERROR_HERE(status);
    }

    if (!status) {
        status = AudioUnitInitialize(audioUnit);
        ERROR_HERE(status);
    }

	status = AudioOutputUnitStart(audioUnit);
    ERROR_HERE(status);
}

OSStatus
audioUnitCallback(void                        *inRefCon,
                  AudioUnitRenderActionFlags  *ioActionFlags,
                  const AudioTimeStamp        *inTimeStamp,
                  UInt32                       inBusNumber,
                  UInt32                       inNumberFrames,
                  AudioBufferList             *ioData)
{
    IRMorsePlayerOperation *self = (__bridge IRMorsePlayerOperation*)inRefCon;
    return [self audioUnitCallback:ioActionFlags
                         timestamp:inTimeStamp
                         busNumber:inBusNumber
                      numberFrames:inNumberFrames
                              data:ioData];
}

- (OSStatus) audioUnitCallback:(AudioUnitRenderActionFlags *)ioActionFlags
                     timestamp:(const AudioTimeStamp       *)inTimeStamp
                     busNumber:(UInt32                      )inBusNumber
                  numberFrames:(UInt32                      )inNumberFrames
                          data:(AudioBufferList            *)ioData
{
    static bool lastSampleSilence = YES;
    static int shouldFinishCounter = 10;
    bool hasSamples = NO;
    // LOG( @"flags:%u", *ioActionFlags );

    if ( ! _sequence ) { return noErr; }

    for(UInt32 i = 0; i < ioData->mNumberBuffers; i++) {
        Sample * samples     = (Sample*)ioData->mBuffers[i].mData;
        size_t samplesToFill = ioData->mBuffers[i].mDataByteSize / sizeof(Sample) / NUM_CHANNELS;

        while ( samplesToFill && (_nextIndex != _sequenceCount) ) {
            hasSamples = YES;
            shouldFinishCounter = 10; // reset

            size_t nextSamples;
            if (samplesToFill > _remainingSamplesOfIndex) {
                nextSamples = _remainingSamplesOfIndex;
            }
            else {
                nextSamples = samplesToFill;
            }

            uint8_t sound = _sequence[ _nextIndex ];
            if (sound == SOUND_SILENCE) {
                lastSampleSilence = YES;

                // silence
                for (size_t n = 0; n < nextSamples; n ++) {
                    for (int c = 0; c < NUM_CHANNELS; c ++) {
                        samples[n * NUM_CHANNELS + c] = 0;
                    }
                }
            }
            else {
                if (lastSampleSilence) {
                    [_producer setSampleRate:SAMPLE_RATE];
                    lastSampleSilence = NO;
                }

                // sine wave
                [_producer produceSamples:samples size:nextSamples];
            }
            if (sound == SOUND_SINE_FADEOUT) {
                // post process fadeout
//                size_t fadeOutSamplesCount = _samplesPerUnit / 100;
                size_t fadeOutSamplesCount = 3;
                for (size_t n = 0; n < fadeOutSamplesCount; n++) {
                    float fadeOutGain = (float)n / (float)fadeOutSamplesCount;
                    Sample value = samples[(nextSamples - n -1) * NUM_CHANNELS];
                    value        = (Sample)( (float)value * fadeOutGain );
                    for (int c = 0; c < NUM_CHANNELS; c ++) {
                        samples[(nextSamples - n - 1) * NUM_CHANNELS + c] = value;
                    }
                }
            }

            _remainingSamplesOfIndex -= nextSamples;
            samplesToFill            -= nextSamples;
            samples                  += nextSamples;

            if (_remainingSamplesOfIndex == 0) {
                _nextIndex ++;
                _remainingSamplesOfIndex = _samplesPerUnit;
            }
        }

        if (! hasSamples && (shouldFinishCounter > 0)) {
            // fill silence after morse for some time
            shouldFinishCounter --;
            for (size_t n = 0; n < samplesToFill; n ++) {
                for (int c = 0; c < NUM_CHANNELS; c ++) {
                    samples[n * NUM_CHANNELS + c] = 0;
                }
            }
        }
    }

    if (shouldFinishCounter == 0) {
        [self finish];
    }
    return noErr;
}

- (void) finish {
    LOG_CURRENT_METHOD;

    // TODO how to avoid this? ERROR:     233: Someone is deleting an AudioConverter while it is in use.

    AudioOutputUnitStop(audioUnit);
    AudioUnitUninitialize(audioUnit);
    AudioComponentInstanceDispose(audioUnit);
    audioUnit = nil;

    free(_sequence); _sequence = 0;

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

@implementation SineWave {
    int32_t c; ///< The coefficient in the resonant filter
    Sample s1; ///< The previous output sample
    Sample s2; ///< The output sample before last
}

/// The scaling factor to apply after multiplication by the
/// coefficient
static const int32_t scale = (1<<29);

#pragma mark - Public

- (id) init {
    if ((self = [super init])) {
        _sampleRate = 44100;
        _peak       = 0x7fff;
        _frequency  = 523.8;
        [self setUp];
    }
    return self;
}

- (void) setSampleRate:(float)newSampleRate {
    _sampleRate = newSampleRate;
    [self setUp];
}

- (void) setPeakLevel:(Sample)newPeak {
    _peak = newPeak;
    [self setUp];
}

- (void) setFrequency:(float)newFrequency {
    _frequency = newFrequency;
    [self setUp];
}

- (void) produceSamples:(Sample *)audioBuffer size:(size_t)size {
    fprintf(stderr, ".");

    for (size_t n = 0; n < size; n ++) {
        Sample next = [self nextSample];
        for (int c = 0; c < NUM_CHANNELS; c ++) {
            audioBuffer[n * NUM_CHANNELS + c] = next;
        }
    }
}

#pragma mark - Private

- (void) setUp {
    double step = 2.0 * M_PI * _frequency / _sampleRate;

    c  = (2 * cos(step) * scale);
    s1 = (_peak * sin(-step));
    s2 = (_peak * sin(-2.0*step));
}

- (Sample) nextSample {
    int64_t temp = (int64_t)c * (int64_t)s1;
    Sample result = (temp/scale) - s2;
    s2 = s1;
    s1 = result;
    return result;
}

@end
