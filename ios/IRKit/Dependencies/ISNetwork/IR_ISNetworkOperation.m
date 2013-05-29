#import "IR_ISNetworkOperation.h"
#import "IR_ISNetworkClient.h"

@interface IR_ISNetworkOperation ()

@property BOOL isExecuting;
@property BOOL isFinished;

@end

@implementation IR_ISNetworkOperation 

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
    return YES;
}

#pragma mark -

- (void)start
{
    if (self.isCancelled) {
        self.isExecuting = NO;
        self.isFinished = YES;
        return;
    }
    
    self.isExecuting = YES;
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    
    if (![NSThread isMainThread]) {
        do {
            if (self.isCancelled) {
                self.isExecuting = NO;
                self.isFinished = YES;
                break;
            }
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        } while (self.isExecuting);
    }
}

- (void)cancel
{
    [self.connection cancel];
    [super cancel];
}

#pragma mark - override in subclasses

- (id)processData:(NSData *)data
{
    return data;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = (NSHTTPURLResponse *)response;
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id object = [self processData:self.data];
    if (self.handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.handler(self.response, object, nil);
        });
    }
    
    self.isExecuting = NO;
    self.isFinished = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.handler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.handler(self.response, nil, error);
        });
    }
    
    self.isExecuting = NO;
    self.isFinished = YES;
}

#pragma mark - life cycle

+ (id)operationWithRequest:(NSURLRequest *)request
{
    return [self operationWithRequest:request handler:nil];
}

+ (id)operationWithRequest:(NSURLRequest *)request handler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    IR_ISNetworkOperation *operation = [[[self class] alloc] init];
    operation.request = request;
    operation.handler = handler;
    
    return operation;
}

#pragma mark - depricated

+ (NSOperationQueue *)sharedOperationQueue
{
    return [IR_ISNetworkClient sharedClient].operationQueue;
}

+ (void)sendRequest:(NSURLRequest *)request handler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    IR_ISNetworkOperation *operation = [self operationWithRequest:request handler:handler];
    [[IR_ISNetworkClient sharedClient].operationQueue addOperation:operation];
}

- (void)enqueueWithHandler:(void (^)(NSHTTPURLResponse *, id, NSError *))handler
{
    self.handler = handler;
    [[IR_ISNetworkClient sharedClient].operationQueue addOperation:self];
}

@end
