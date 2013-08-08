#import <Foundation/Foundation.h>

@interface IRSignalSendOperationQueue : NSOperationQueue

@property (nonatomic, copy) void (^completion)(NSError *error);
@property (nonatomic) NSError *error;

@end
