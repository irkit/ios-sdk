#import "IR_ISNetworkClient.h"
#import "IR_ISNetworkOperation.h"

@interface IR_ISNetworkClient ()

@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end


@implementation IR_ISNetworkClient

#pragma mark - shortcuts

+ (void)cancelAllOperations
{
    [[self sharedClient].operationQueue cancelAllOperations];
}

+ (void)sendRequest:(NSURLRequest *)request
     operationClass:(Class)operationClass
            handler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    if ([operationClass resolveClassMethod:@selector(operationWithRequest:handler:)]) {
        NSLog(@"invalid operation class.");
        return;
    }
    IR_ISNetworkClient *client = [IR_ISNetworkClient sharedClient];
    IR_ISNetworkOperation *operation = [operationClass operationWithRequest:request handler:handler];
    if (!operation) {
        NSLog(@"could not construct operation.");
        return;
    }
    
    [client.operationQueue addOperation:operation];
}

+ (void)sendRequest:(NSURLRequest *)request handler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    [self sendRequest:request
       operationClass:[IR_ISNetworkOperation class]
              handler:handler];
}

#pragma mark - life cycle

+ (IR_ISNetworkClient *)sharedClient
{
    static IR_ISNetworkClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[self alloc] init];
    });
    
    return client;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.managesActivityIndicator = YES;
        self.operationQueue = [[NSOperationQueue alloc] init];
        
        [self.operationQueue addObserver:self
                              forKeyPath:@"operationCount"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    }
    return self;
}


#pragma mark - key value observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.operationQueue && [keyPath isEqualToString:@"operationCount"]) {
        [self updateIndicatorVisible];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateIndicatorVisible
{
    if (!self.managesActivityIndicator) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL remaining = self.operationQueue.operationCount ? YES : NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = remaining;
    });
}

@end
