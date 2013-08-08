#import "IRChartView.h"

#define LOG_DISABLED 1

#define MARGIN_TOP    10.
#define PADDING_BOTTOM 10.
#define INTERVAL_MARGIN_LEFT   0.
#define INTERVAL_MARGIN_RIGHT  0.
#define INTERVAL_BEFORE_LEADER 50.
#define INTERVAL_AFTER_STOP    50.

@implementation IRChartView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

- (NSUInteger) sumOfData {
    if ( ! _data.count ) {
        return 0;
    }
    __block NSUInteger sum = 0;
    [_data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        sum += [obj shortValue];
    }];
    return sum;
}

- (CGMutablePathRef)chartTopLinePath {
    LOG( @"frame.width: %f", self.frame.size.width );
    double sum           = (double)[self sumOfData];
    double intervalScale = self.frame.size.width / (INTERVAL_MARGIN_LEFT + INTERVAL_BEFORE_LEADER + sum + INTERVAL_AFTER_STOP + INTERVAL_MARGIN_RIGHT);
    LOG( @"intervalScale: %f", intervalScale );
    double topY          = MARGIN_TOP;
    double bottomY       = self.frame.size.height - PADDING_BOTTOM;
    double bottomLineY   = self.frame.size.height;

    CGMutablePathRef path = CGPathCreateMutable();
    // start from bottom-left
    double rightX = INTERVAL_MARGIN_LEFT;
    LOG( @"rightX: %f", rightX);
    CGPathMoveToPoint(path, NULL,    rightX*intervalScale,
                                     topY);
    // →
    rightX = INTERVAL_MARGIN_LEFT + INTERVAL_BEFORE_LEADER;
    LOG( @"rightX: %f", rightX);
    CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                     topY);
    // data.count is an ODD number
    for (int i=0; (_data.count && (i<_data.count-1)); i+=2) {
        uint16_t lowInterval  = [_data[i]   shortValue];
        uint16_t highInterval = [_data[i+1] shortValue];

        // from top-left
        // ↓
        CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                         bottomY);
        // →
        rightX += lowInterval;
        LOG( @"rightX: %f", rightX);
        CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                         bottomY);
        // ↑
        CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                         topY);
        // →
        rightX += highInterval;
        LOG( @"rightX: %f", rightX);
        CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                         topY);
        // finishes on top-right
    }
    // manually draw last (ODD) number
    // ↓
    CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                     bottomY);
    // →
    rightX += (double)(_data.count ? [_data[_data.count-1] shortValue] : 0);
    LOG( @"rightX: %f", rightX);
    CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                     bottomY);
    // ↑
    CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                     topY);
    // →
    rightX = INTERVAL_MARGIN_LEFT + INTERVAL_BEFORE_LEADER + sum + INTERVAL_AFTER_STOP;
    LOG( @"rightX: %f", rightX);
    CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                     topY);
    return path;
}

-(void)drawInContext:(CGContextRef)context
{
    LOG_CURRENT_METHOD;

    CGContextSetStrokeColorWithColor(context, [UIColor cyanColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetShouldAntialias(context, NO);
    CGContextSetAllowsAntialiasing(context, NO);

    CGMutablePathRef topLinePath    = [self chartTopLinePath];
    CGContextAddPath(context,topLinePath);
    CGContextAddPath(context,topLinePath);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(topLinePath);
}

@end
