#import "IRFunc.h"

NSString *NSStringFromCBCentralManagerState(CBCentralManagerState state)
{
    NSString *ret;
    switch (state) {
        case CBCentralManagerStateUnknown:
            ret = @"Unknown";
            break;
        case CBCentralManagerStateResetting:
            ret = @"Resetting";
            break;
        case CBCentralManagerStateUnsupported:
            ret = @"Unsupported";
            break;
        case CBCentralManagerStateUnauthorized:
            ret = @"Unauthorized";
            break;
        case CBCentralManagerStatePoweredOff:
            ret = @"PoweredOff";
            break;
        case CBCentralManagerStatePoweredOn:
            ret = @"PoweredOn";
            break;
        default:
            ret = @"*UNEXPECTED STATE*";
    }
    return ret;
}
