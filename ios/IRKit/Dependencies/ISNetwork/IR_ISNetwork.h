#import "IR_ISNetworkClient.h"
#import "IR_ISNetworkOperation.h"
#import "IR_ISJSONNetworkOperation.h"
#import "IR_ISImageNetworkOperation.h"

typedef enum {
    IR_ISHTTPMethodGET = 0,
    IR_ISHTTPMethodPOST,
    IR_ISHTTPMethodPUT,
    IR_ISHTTPMethodDELETE,
    IR_ISHTTPMethodPATCH,
} IR_ISHTTPMethod;