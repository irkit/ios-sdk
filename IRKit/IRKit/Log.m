#import "Log.h"

NSString *_IRLog(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args]; // ARC
    va_end(args);
    return str;
}
