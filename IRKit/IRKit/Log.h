#import <Foundation/Foundation.h>

NSString * _IRLog(NSString *format, ...);
void IRKitLog(NSString *msg);

// '#define LOG_DISABLED 1' before '#import "Log.h"' in .m file to disable logging only in that file
#ifndef LOG_DISABLED
# define LOG_DISABLED       0
#endif

#if (defined(IRKIT_DEBUG) && !LOG_DISABLED)
# define LOG_CURRENT_METHOD NSLog(@ "%s#%d", __PRETTY_FUNCTION__, __LINE__)
# define LOG(...) NSLog(@ "%s#%d %@", __PRETTY_FUNCTION__, __LINE__, _IRLog(__VA_ARGS__))
#
#else
#  define LOG_CURRENT_METHOD
#  define LOG(...)
#
#endif

#ifdef IRKIT_DEBUG
# define ASSERT(A, B) NSAssert(A, B)
#else
# define ASSERT(A, B)
#endif
