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
@import AVFoundation;

#define OUTPUT_BUS          0
#define SAMPLE_RATE         44100
#define ASSERT_OR_RETURN(status) \
 if (status) { \
  NSError *e = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]; \
  LOG( @"status: %ld error: %@", status, e ); \
  return; \
 }

#define LONGEST_CHARACTER_LENGTH 7 // $
#define SOUND_SILENCE      0
#define SOUND_SINE         1
#define POST_SILENCE_TIME  30
#define FREQ_SINE          523.8
#define FREQ_CUTOFF        600.

@interface IRMorsePlayerOperation ()

@property BOOL isExecuting;
@property BOOL isFinished;

@property (nonatomic) NSString *string;
@property (nonatomic) NSNumber *wpm;
@property (nonatomic) SineWave *producer;

@end

@implementation IRMorsePlayerOperation {
    AUGraph _graph;
    bool *_sequence;
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

    [self initializeAUGraph];
    [self play];
}

+ (IRMorsePlayerOperation*) playMorseFromString:(NSString*)input
                                  withWordSpeed:(NSNumber*)wpm {
    LOG_CURRENT_METHOD;

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
                _sequence[ sequenceIndex ++ ] = SOUND_SINE;
            }
            else if (shortOrLong == '1' ) {
                // long
                _sequence[ sequenceIndex ++ ] = SOUND_SINE;
                _sequence[ sequenceIndex ++ ] = SOUND_SINE;
                _sequence[ sequenceIndex ++ ] = SOUND_SINE;
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

- (void) initializeAUGraph {
    NSError *error = nil;
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    [sessionInstance setPreferredSampleRate:SAMPLE_RATE error:&error];
    if (error) { LOG( @"error: %@", error ); return; }

    [sessionInstance setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) { LOG( @"error: %@", error ); return; }

//    // add interruption handler
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleInterruption:)
//                                                 name:AVAudioSessionInterruptionNotification
//                                               object:sessionInstance];
//
//    // we don't do anything special in the route change notification
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleRouteChange:)
//                                                 name:AVAudioSessionRouteChangeNotification
//                                               object:sessionInstance];












    
    [sessionInstance setActive:YES error:&error];

    AUNode morsePlayerNode;
    AUNode converterNode;
    AUNode filterNode;
    AUNode outputNode;
    OSStatus result = noErr;

    // create a new AUGraph
    result = NewAUGraph(&_graph);
    ASSERT_OR_RETURN(result);

    // morse player unit
    AudioComponentDescription morsePlayerDescription;
    morsePlayerDescription.componentType         = kAudioUnitType_Mixer;
    morsePlayerDescription.componentSubType      = kAudioUnitSubType_MultiChannelMixer;
    morsePlayerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    morsePlayerDescription.componentFlags        = 0;
    morsePlayerDescription.componentFlagsMask    = 0;
    result = AUGraphAddNode(_graph, &morsePlayerDescription, &morsePlayerNode);
    ASSERT_OR_RETURN(result);

    // converter unit
    AudioComponentDescription converterDescription;
    converterDescription.componentType         = kAudioUnitType_FormatConverter;
    converterDescription.componentSubType      = kAudioUnitSubType_AUConverter;
    converterDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    converterDescription.componentFlags        = 0;
    converterDescription.componentFlagsMask    = 0;
    result = AUGraphAddNode(_graph, &converterDescription, &converterNode);
    ASSERT_OR_RETURN(result);

    // low pass filter unit
    AudioComponentDescription filterDescription;
    filterDescription.componentType         = kAudioUnitType_Effect;
    filterDescription.componentSubType      = kAudioUnitSubType_LowPassFilter;
    filterDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    filterDescription.componentFlags        = 0;
    filterDescription.componentFlagsMask    = 0;
    result = AUGraphAddNode(_graph, &filterDescription, &filterNode);
    ASSERT_OR_RETURN(result);

    // output unit
    AudioComponentDescription outputDescription;
    outputDescription.componentType         = kAudioUnitType_Output;
    outputDescription.componentSubType      = kAudioUnitSubType_RemoteIO;
    outputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    outputDescription.componentFlags        = 0;
    outputDescription.componentFlagsMask    = 0;
    result = AUGraphAddNode (_graph, &outputDescription, &outputNode);
    ASSERT_OR_RETURN(result);

    // morse -> converter -> low pass -> output

    result = AUGraphConnectNodeInput(_graph, morsePlayerNode, 0, converterNode, 0);
    ASSERT_OR_RETURN(result);

    result = AUGraphConnectNodeInput(_graph, converterNode, 0, filterNode, 0);
    ASSERT_OR_RETURN(result);

    result = AUGraphConnectNodeInput(_graph, filterNode, 0, outputNode, 0);
    ASSERT_OR_RETURN(result);

    result = AUGraphOpen(_graph);
    ASSERT_OR_RETURN(result);

    AudioUnit morsePlayerUnit, filterUnit, converterUnit;
    result = AUGraphNodeInfo(_graph, morsePlayerNode, NULL, &morsePlayerUnit);
    ASSERT_OR_RETURN(result);

    result = AUGraphNodeInfo(_graph, filterNode, NULL, &filterUnit);
    ASSERT_OR_RETURN(result);

    result = AUGraphNodeInfo(_graph, converterNode, NULL, &converterUnit);
    ASSERT_OR_RETURN(result);

    AudioStreamBasicDescription audioFormat;
    size_t bytesPerSample = sizeof (Sample);
    audioFormat.mSampleRate         = SAMPLE_RATE;
    audioFormat.mFormatID           = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mChannelsPerFrame   = 1; // MONO
    audioFormat.mBitsPerChannel     = bytesPerSample * 8;
    audioFormat.mBytesPerPacket     = bytesPerSample;
    audioFormat.mBytesPerFrame      = bytesPerSample;

    // stream formats

    result = AudioUnitSetProperty(morsePlayerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &audioFormat, sizeof(audioFormat));
    ASSERT_OR_RETURN(result);

    result = AudioUnitSetProperty(morsePlayerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &audioFormat, sizeof(audioFormat));
    ASSERT_OR_RETURN(result);

    result = AudioUnitSetProperty(converterUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &audioFormat, sizeof(audioFormat));
    ASSERT_OR_RETURN(result);

    // mFormatFlags: 41
    // kAudioFormatFlagIsNonInterleaved | kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat
    size_t size = sizeof(audioFormat);
    result = AudioUnitGetProperty(filterUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &audioFormat, &size);
    ASSERT_OR_RETURN(result);

    result = AudioUnitSetProperty(converterUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &audioFormat, sizeof(audioFormat));
    ASSERT_OR_RETURN(result);

    // others

    result = AudioUnitSetParameter(filterUnit, kAudioUnitScope_Global, 0, kLowPassParam_CutoffFrequency, FREQ_CUTOFF, 0);
    ASSERT_OR_RETURN(result);

    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc       = audioUnitCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);

    result = AudioUnitSetProperty(morsePlayerUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, OUTPUT_BUS, &callbackStruct, sizeof(callbackStruct));
    ASSERT_OR_RETURN(result);

    result = AUGraphInitialize(_graph);
    ASSERT_OR_RETURN(result);
}

- (void) play {
    OSStatus result = AUGraphStart(_graph);
    ASSERT_OR_RETURN(result);
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
    static int shouldFinishCounter = POST_SILENCE_TIME;
    bool hasSamples = NO;

    if ( ! _sequence ) { return noErr; }

    // we use Monoral
    // mNumberBuffers is 1 anyway
    Sample * samples     = (Sample*)ioData->mBuffers[0].mData;
    size_t samplesToFill = ioData->mBuffers[0].mDataByteSize / sizeof(Sample);

    while ( samplesToFill && (_nextIndex != _sequenceCount) ) {
        hasSamples = YES;
        shouldFinishCounter = POST_SILENCE_TIME; // reset

        size_t nextSamples;
        if (samplesToFill > _remainingSamplesOfIndex) {
            nextSamples = _remainingSamplesOfIndex;
        }
        else {
            nextSamples = samplesToFill;
        }

        bool sound = _sequence[ _nextIndex ];
        if (sound == SOUND_SILENCE) {
            lastSampleSilence = YES;

            // silence
            for (size_t n = 0; n < nextSamples; n ++) {
                samples[n] = 0;
            }
        }
        else {
            // sine wave
            [_producer produceSamples:samples size:nextSamples];
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
            samples[n] = 0;
        }
    }

    if (shouldFinishCounter == 0) {
        [self finish];
    }
    return noErr;
}

- (void) finish {
    LOG_CURRENT_METHOD;

    AUGraphStop(_graph);

    free(_sequence); _sequence = 0;

    self.isExecuting = NO;
    self.isFinished  = YES;
}

- (void) dealloc {
    LOG_CURRENT_METHOD;
    DisposeAUGraph(_graph);
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

// thanks to http://goodliffe.blogspot.jp/2010_11_01_archive.html
// equation looks like that from http://www.musicdsp.org/pdf/musicdsp.pdf 's fast sine calculation
@implementation SineWave {
    int32_t c; ///< The coefficient in the resonant filter
    Sample s1; ///< The previous output sample
    Sample s2; ///< The output sample before last
    float  frequency;
    Sample peak;
    float  sampleRate;
}

// The scaling factor to apply after multiplication by the
// coefficient
static const int32_t scale = (1<<29);

#pragma mark - Public

- (id) init {
    if ((self = [super init])) {
        sampleRate = SAMPLE_RATE;
        peak       = 0x7fff;
        frequency  = FREQ_SINE;
        [self setUp];
    }
    return self;
}

- (void) produceSamples:(Sample *)audioBuffer size:(size_t)size {
#ifdef DEBUG
    fprintf(stderr, ".");
#endif

    for (size_t n = 0; n < size; n ++) {
        audioBuffer[n] = [self nextSample];
    }
}

#pragma mark - Private

- (void) setUp {
    double step = 2.0 * M_PI * frequency / sampleRate;

    c  = (2 * cos(step) * scale);
    s1 = (peak * sin(-step));
    s2 = (peak * sin(-2.0*step));
}

- (Sample) nextSample {
    int64_t temp = (int64_t)c * (int64_t)s1;
    Sample result = (temp/scale) - s2;
    s2 = s1;
    s1 = result;
    return result;
}

@end
