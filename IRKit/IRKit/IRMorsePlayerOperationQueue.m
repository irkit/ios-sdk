#import "Log.h"
#import "IRMorsePlayerOperationQueue.h"

@interface IRMorsePlayerOperationQueue ()
@end

@implementation IRMorsePlayerOperationQueue

- (instancetype) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }

    [self setMaxConcurrentOperationCount:1];
    return self;
}

#pragma mark - Private methods

@end
