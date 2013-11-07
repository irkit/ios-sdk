#import "Log.h"
#import "IREditCell.h"

@interface IREditCell ()

@end

@implementation IREditCell

- (void)awakeFromNib {
    LOG_CURRENT_METHOD;
    [super awakeFromNib];
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
}

@end
