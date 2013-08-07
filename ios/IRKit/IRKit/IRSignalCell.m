#import "IRSignalCell.h"
#import "IRChartView.h"

static NSDateFormatter *dateFormatter;

@interface IRSignalCell ()

@end

@implementation IRSignalCell

+ (void)load {
    // tell linker we need this class
    [IRChartView class];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)inflateFromSignal:(IRSignal*)signal {
    LOG( @"signal: %@", signal);
    
    _nameLabel.text         = signal.name;
    _receivedDateLabel.text = [dateFormatter stringFromDate:signal.receivedDate];
    _signalChartView.data   = signal.data;
    [_signalChartView setNeedsDisplay];
}

+ (CGFloat)height {
    return 150.;
}

@end
