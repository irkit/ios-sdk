#import <Foundation/Foundation.h>
#import "IRPeripheral.h"

@interface IRSignal : NSObject

- (id) initWithDictionary: (NSDictionary*) dictionary;
- (id) initWithDictionary: (NSDictionary*) dictionary fromHostname:(NSString*)hostname;
- (NSDictionary*)asDictionary;
- (NSComparisonResult) compareByReceivedDate: (IRSignal*) otherSignal;
- (void)sendWithCompletion: (void (^)(NSError* error))block;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSArray *data;
@property (nonatomic) NSString *format; // "raw" only for now
@property (nonatomic) NSNumber *frequency; // kHz
@property (nonatomic) NSDate *receivedDate;
@property (nonatomic) IRPeripheral *peripheral;

@end
