#import "Log.h"
#import "IRSignalSendOperationQueue.h"
#import "IRPeripheralWriteOperation.h"

@interface IRSignalSendOperationQueue ()
@end

@implementation IRSignalSendOperationQueue

- (id) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }

    [self setSuspended:NO];
    [self setMaxConcurrentOperationCount:1];

    [self addObserver:self
           forKeyPath:@"operationCount"
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:nil];

    return self;
}

- (void) dealloc {
    LOG_CURRENT_METHOD;
    [self removeObserver:self
              forKeyPath:@"operationCount"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    LOG( @"keyPath: %@", keyPath );

    if ([keyPath isEqualToString:@"operationCount"]) {
        NSObject *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if (newValue && ([(NSNumber*)newValue unsignedIntegerValue]==0)) {
            [self removeObserver:self
                      forKeyPath:@"operationCount"];
            dispatch_async(dispatch_get_main_queue(), ^{
                _completion(_error);
            });
        }
    }
}

@end
