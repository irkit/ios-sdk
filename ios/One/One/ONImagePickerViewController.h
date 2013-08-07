#import <UIKit/UIKit.h>

@protocol ONImagePickerViewControllerDelegate;

@interface ONImagePickerViewController : UIViewController<
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
>

@property (nonatomic, assign) id<ONImagePickerViewControllerDelegate> delegate;

@end

@protocol ONImagePickerViewControllerDelegate <NSObject>

@required
- (void)imagePickerViewController:(ONImagePickerViewController*)viewController
                     didPickImage:(UIImage*)image
                         withName:(NSString*)name;

@end
