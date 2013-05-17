#import <Foundation/Foundation.h>

NSString *sp(NSString *format, ...);

#ifdef FORCE_LOG
#  define LOG_CURRENT_METHOD NSLog(@"%s#%d",      __PRETTY_FUNCTION__, __LINE__)
#  define LOG(...)           NSLog(@"%s#%d %@", __PRETTY_FUNCTION__, __LINE__, sp(__VA_ARGS__))
#
#elif defined DEBUG
#  define LOG_CURRENT_METHOD NSLog(@"%s#%d",      __PRETTY_FUNCTION__, __LINE__)
#  define LOG(...)           NSLog(@"%s#%d %@", __PRETTY_FUNCTION__, __LINE__, sp(__VA_ARGS__))
#
#else
#  define LOG(...)           ()
#  define LOG_CURRENT_METHOD ()
#
#endif
