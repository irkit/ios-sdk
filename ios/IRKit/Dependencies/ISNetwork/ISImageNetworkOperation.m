#import "ISImageNetworkOperation.h"

@implementation ISImageNetworkOperation

- (id)processData:(NSData *)data
{
    return [UIImage imageWithData:data];
}

@end
