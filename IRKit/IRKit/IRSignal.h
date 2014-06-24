#import <Foundation/Foundation.h>
#import "IRPeripheral.h"

@protocol IRSendable

@required
/// Send this!
/// You need to set `peripheral` or `hostname` readwrite property,
/// to specify from which IRKit device to send this.
- (void)sendWithCompletion:(void (^) (NSError * error))block;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/// Public, safe to share information about IR signal.
/// You can transfer this dictionary to other end users and `initWithDictionary:`
/// to instantiate a copy.
/// Set `peripheral` or `hostname` readwrite property,
/// to specify from which IRKit device to send this.
- (NSDictionary *)asPublicDictionary;

/// Includes enough information to send this signal from one IRKit.
/// Does include IRKit device's hostname but not it's deviceid (valid only when used with it's paired clientid).
/// Use this to share signal information within multiple clients used against single IRKit device.
/// ex: OK to Share between multiple client apps on single iPhone/Mac
- (NSDictionary *)asSendableDictionary;

/// Includes information about end user's IRKit device's hostname and so on,
/// so use `asPublicDictionary` when you want to share signal information over to other end users.
/// Use this to backup signals information inside single app.
- (NSDictionary *)asDictionary;

@end

@interface IRSignal : NSObject<IRSendable, NSCoding>

#pragma mark - included in asPublicDictionary

@property (nonatomic) NSArray *data;

/// "raw" only for now
@property (nonatomic, copy) NSString *format;

/// kHz
@property (nonatomic) NSNumber *frequency;

#pragma mark - also included in asDictionary

@property (nonatomic) IRPeripheral *peripheral;
@property (nonatomic, copy) NSString *hostname;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSDictionary *custom;

@end
