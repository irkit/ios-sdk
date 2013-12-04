#import <UIKit/UIKit.h>

@protocol IRNewPeripheralScene1ViewControllerDelegate;

@interface IRNewPeripheralScene1ViewController : UIViewController

@property (nonatomic, weak) id<IRNewPeripheralScene1ViewControllerDelegate> delegate;

@end

@protocol IRNewPeripheralScene1ViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)scene1ViewController:(IRNewPeripheralScene1ViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
