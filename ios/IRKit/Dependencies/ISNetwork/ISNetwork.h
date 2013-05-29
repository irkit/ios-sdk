#import "ISNetworkClient.h"
#import "ISNetworkOperation.h"
#import "ISJSONNetworkOperation.h"
#import "ISImageNetworkOperation.h"

typedef enum {
    ISHTTPMethodGET = 0,
    ISHTTPMethodPOST,
    ISHTTPMethodPUT,
    ISHTTPMethodDELETE,
    ISHTTPMethodPATCH,
} ISHTTPMethod;