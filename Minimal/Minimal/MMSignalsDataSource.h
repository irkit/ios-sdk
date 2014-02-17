#import <Foundation/Foundation.h>
#import <IRKit/IRKit.h>

@interface MMSignalsDataSource : NSObject<UITableViewDataSource>

- (void)addSignalsObject: (IRSignal*) signal;
- (IRSignal*)objectAtIndex: (NSUInteger) index;

@end
