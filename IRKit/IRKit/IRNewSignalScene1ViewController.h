#import <UIKit/UIKit.h>

// pre definition for delegate
@protocol IRNewSignalScene1ViewControllerDelegate;

@interface IRNewSignalScene1ViewController : UIViewController

@property (nonatomic, weak) id<IRNewSignalScene1ViewControllerDelegate> delegate;

@end

@protocol IRNewSignalScene1ViewControllerDelegate <NSObject>

@required

// Your implementation of this method should dismiss view controller.
- (void)scene1ViewController:(IRNewSignalScene1ViewController *)viewController didFinishWithInfo:(NSDictionary *)info;

@end
