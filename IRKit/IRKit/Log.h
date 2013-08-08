#import <Foundation/Foundation.h>

NSString *sp(NSString *format, ...);

// define 1 if you want logging disabled only in that .m file
#define LOG_DISABLED 0

// can't help using runtime "if" (wanna use "#if")
// but to place "#import 'Log.h'" in *.pch file and not in each .m files...
#if defined(FORCE_LOG) || defined(DEBUG)
# define LOG_CURRENT_METHOD if (! LOG_DISABLED) NSLog(@"%s#%d", __PRETTY_FUNCTION__, __LINE__)
# define LOG(...)           if (! LOG_DISABLED) NSLog(@"%s#%d %@", __PRETTY_FUNCTION__, __LINE__, sp(__VA_ARGS__))
#
#else
#  define LOG_CURRENT_METHOD 
#  define LOG(...)
#
#endif

#ifdef DEBUG
# define ASSERT(A,B) NSAssert(A,B)
#else
# define ASSERT(A,B)
#endif
