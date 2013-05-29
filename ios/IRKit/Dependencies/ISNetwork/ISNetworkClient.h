#import <Foundation/Foundation.h>

@interface ISNetworkClient : NSObject

@property BOOL managesActivityIndicator;
@property (readonly, strong, nonatomic) NSOperationQueue *operationQueue;

+ (ISNetworkClient *)sharedClient;

+ (void)cancelAllOperations;
+ (void)sendRequest:(NSURLRequest *)request handler:(void (^)(NSHTTPURLResponse *response, id object, NSError *error))handler;
+ (void)sendRequest:(NSURLRequest *)request
     operationClass:(Class)operationClass
            handler:(void (^)(NSHTTPURLResponse *response, id object, NSError *error))handler;

@end
