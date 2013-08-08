#import <UIKit/UIKit.h>
#import "IRNewPeripheralScene1ViewController.h"
#import "IRNewPeripheralScene2ViewController.h"
#import "IRPeripheralNameEditViewController.h"

// pre definition for delegate
@protocol IRNewPeripheralViewControllerDelegate;

@interface IRNewPeripheralViewController : UIViewController<IRNewPeripheralScene1ViewControllerDelegate>

@property (nonatomic, assign) id<IRNewPeripheralViewControllerDelegate> delegate;

@end

@protocol IRNewPeripheralViewControllerDelegate <NSObject>

@required

// Your implementation of this method should dismiss view controller.
- (void)newPeripheralViewController:(IRNewPeripheralViewController*)viewController didFinishWithPeripheral:(IRPeripheral*)peripheral;

@end
