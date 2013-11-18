#import <UIKit/UIKit.h>

@protocol IRMorsePlayerViewControllerDelegate;

@interface IRMorsePlayerViewController : UIViewController

@property (nonatomic, assign) id<IRMorsePlayerViewControllerDelegate> delegate;

@end

@protocol IRMorsePlayerViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)morsePlayerViewController:(IRMorsePlayerViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
