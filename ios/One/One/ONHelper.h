#import <Foundation/Foundation.h>
#import <IRKit/IRKit.h>

@interface ONHelper : NSObject

+ (void)createIcon:(UIImage *)image
        forSignals:(IRSignals*)signals
          completionHandler:(void (^)(NSHTTPURLResponse *response, NSDictionary *json, NSError *error)) handler;

@end
