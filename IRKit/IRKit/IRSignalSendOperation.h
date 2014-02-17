#import <Foundation/Foundation.h>
#import "IRSignal.h"

@interface IRSignalSendOperation : NSOperation

@property (nonatomic) IRSignal *signal;

- (id)initWithSignal:(IRSignal *)signal
          completion:(void(^) (NSError * error))completion;

@end
