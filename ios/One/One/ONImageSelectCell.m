#import "ONImageSelectCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ONImageSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _iconImageView.layer.cornerRadius = 10.;
        _iconImageView.clipsToBounds = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIconImage:(UIImage *)iconImage {
    _iconImageView.image = iconImage;
    _iconImageView.layer.cornerRadius = 10.;
    _iconImageView.clipsToBounds = YES;
}

- (UIImage*)iconImage {
    return _iconImageView.image;
}

@end
