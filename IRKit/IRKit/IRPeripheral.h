// IRPeripheral is a IRKit device representation
#import <Foundation/Foundation.h>

@interface IRPeripheral : NSObject

@property (nonatomic, copy) NSString *hostname;
@property (nonatomic, copy) NSString *customizedName;
@property (nonatomic, copy) NSDate *foundDate;
@property (nonatomic, copy) NSString *deviceid;

@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *regdomain; // for debug purpose only

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL)hasDeviceID;
- (void)setHostname:(NSString *)hostname;
- (NSString *)local_hostname;

// this takes time on 1st call, so you might want to prefetch on viewDidLoad or something
- (BOOL)isReachableViaWifi;

- (void)getKeyWithCompletion:(void (^) ())successfulCompletion;
- (void)getModelNameAndVersionWithCompletion:(void (^) ())successfulCompletion;
- (NSComparisonResult)compareByFirstFoundDate:(IRPeripheral *)otherPeripheral;

- (NSString *)iconURL;
- (NSString *)modelNameAndRevision;

- (NSDictionary *)asDictionary;
- (void)inflateFromDictionary:(NSDictionary *)dictionary;

@end
