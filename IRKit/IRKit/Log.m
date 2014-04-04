#import "Log.h"

NSString * _IRLog(NSString *format, ...) {
    va_list args;

    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat: format arguments: args];
    va_end(args);
    return str;
}

void IRKitLog(NSString *msg) {
    NSLog(@"[IRKit]%@", msg);
}