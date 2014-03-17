#import <UIKit/UIKit.h>

@protocol IRGuidePowerViewControllerDelegate;

@interface IRGuidePowerViewController : UIViewController

@property (nonatomic, weak) id<IRGuidePowerViewControllerDelegate> delegate;

@end

@protocol IRGuidePowerViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)scene1ViewController:(IRGuidePowerViewController *)viewController didFinishWithInfo:(NSDictionary *)info;

@end
