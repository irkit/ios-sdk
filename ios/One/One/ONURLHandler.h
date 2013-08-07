#import <Foundation/Foundation.h>
#import <IRKit/IRKit.h>

@interface ONURLHandler : NSObject

+ (BOOL) canHandleOpenURL: (NSURL*)url;
+ (void) handleOpenURL: (NSURL*)url;
+ (NSArray*)signalsDictionariesFromURL:(NSURL*)url;
+ (IRSignals*)signalsFromURL:(NSURL*)url;

@end
