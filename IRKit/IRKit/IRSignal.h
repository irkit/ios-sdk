#import <Foundation/Foundation.h>
#import "IRPeripheral.h"

@interface IRSignal : NSObject

- (id) initWithDictionary: (NSDictionary*) dictionary;
- (NSDictionary*)asDictionary;
- (NSComparisonResult) compareByReceivedDate: (IRSignal*) otherSignal;
- (NSString*) uniqueID;
- (void)sendWithCompletion: (void (^)(NSError* error))block;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSArray *data;
@property (nonatomic) NSUInteger frequency; // kHz
@property (nonatomic) NSDate *receivedDate;
@property (nonatomic) IRPeripheral *peripheral;

@property (nonatomic, copy) NSString* hostname;

@end
