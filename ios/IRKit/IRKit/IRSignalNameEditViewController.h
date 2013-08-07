#import <UIKit/UIKit.h>
#import "IRSignal.h"

@protocol IRSignalNameEditViewControllerDelegate;

@interface IRSignalNameEditViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) id<IRSignalNameEditViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) IRSignal *signal;

@end

@protocol IRSignalNameEditViewControllerDelegate <NSObject>
@required

// Your implementation of this method should dismiss view controller.
- (void)scene2ViewController:(IRSignalNameEditViewController *)viewController didFinishWithInfo:(NSDictionary*)info;

@end
