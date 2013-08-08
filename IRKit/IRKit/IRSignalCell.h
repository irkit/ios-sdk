#import <UIKit/UIKit.h>
#import "IRSignal.h"
#import "IRChartView.h"

@interface IRSignalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *receivedDateLabel;
@property (weak, nonatomic) IBOutlet IRChartView *signalChartView;

+ (CGFloat)height;
- (void)inflateFromSignal:(IRSignal*)signal;

@end
