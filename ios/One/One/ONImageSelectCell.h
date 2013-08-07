#import <UIKit/UIKit.h>

@interface ONImageSelectCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (nonatomic) UIImage *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *iconName;

@end
