#import "IR_ISImageNetworkOperation.h"

@implementation IR_ISImageNetworkOperation

- (id)processData:(NSData *)data
{
    return [UIImage imageWithData:data];
}

@end
