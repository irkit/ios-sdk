#import <UIKit/UIKit.h>
#import "IRPeripheral.h"

@protocol IRNewPeripheralScene2ViewControllerDelegate;

@interface IRNewPeripheralScene2ViewController : UIViewController

@property (nonatomic, weak) id<IRNewPeripheralScene2ViewControllerDelegate> delegate;

@end

@protocol IRNewPeripheralScene2ViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)scene2ViewController:(IRNewPeripheralScene2ViewController *)viewController didFinishWithInfo:(NSDictionary *)info;

@end
