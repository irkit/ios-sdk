//
//  IRChartView.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/21.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRChartView.h"

#define MARGIN_TOP    10.
#define PADDING_BOTTOM 10.
#define INTERVAL_MARGIN_LEFT   0.
#define INTERVAL_MARGIN_RIGHT  0.
#define INTERVAL_BEFORE_LEADER 50.
#define INTERVAL_AFTER_STOP    50.

@implementation IRChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

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
    rightX += (double)[_data[_data.count-1] shortValue];
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

- (CGMutablePathRef)chartBottomLinePath {
    CGMutablePathRef path = CGPathCreateMutable();
    double sum           = (double)[self sumOfData];
    double intervalScale = self.frame.size.width / (INTERVAL_MARGIN_LEFT + INTERVAL_BEFORE_LEADER + sum + INTERVAL_AFTER_STOP + INTERVAL_MARGIN_RIGHT);
    double topY          = MARGIN_TOP;
    double bottomY       = self.frame.size.height - PADDING_BOTTOM;
    double bottomLineY   = self.frame.size.height;

    double rightX = INTERVAL_MARGIN_LEFT + INTERVAL_BEFORE_LEADER + sum + INTERVAL_AFTER_STOP;
    LOG( @"rightX: %f", rightX);
    // right-top
    CGPathMoveToPoint(path, NULL,    rightX*intervalScale,
                                     topY);
    // ↓
    CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                     bottomLineY);
    // ←
    rightX = INTERVAL_MARGIN_LEFT;
    CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                     bottomLineY);
    // ↑
    CGPathAddLineToPoint(path, NULL, rightX*intervalScale,
                                     topY);
    return path;
}

-(void)drawInContext:(CGContextRef)context
{
    LOG_CURRENT_METHOD;
    
    // set clip using chart path
    CGMutablePathRef topLinePath    = [self chartTopLinePath];
    CGMutablePathRef bottomLinePath = [self chartBottomLinePath];
    CGContextAddPath(context,topLinePath);
    CGContextAddPath(context,bottomLinePath);
    CGPathRef outlinePath = CGPathCreateCopyByStrokingPath(topLinePath, NULL, 1, kCGLineCapButt, kCGLineJoinMiter, 0);
    CGPathRelease(topLinePath);
    CGPathRelease(bottomLinePath);

    CGContextSaveGState(context); // clip start
    CGContextClip(context);
    
    // gradient
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {
        0.9f, 0.9f, 1.0f, 1.0f,     // R, G, B, Alpha
        0.9f, 0.9f, 1.0f, 1.0f
    };
    CGFloat locations[] = { 0.0f, 1.0f };
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 4);
    
    CGPoint startPoint = {.x = 0, .y = 0. };
    CGPoint endPoint   = {.x = 0, .y = self.frame.size.height };
    
    CGGradientRef gradientRef =
    CGGradientCreateWithColorComponents(colorSpaceRef, components, locations, count);
    
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                startPoint,
                                endPoint,
                                0);
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    CGContextRestoreGState(context); // clip end

    // add outline
    CGContextAddPath(context, outlinePath);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGPathRelease(outlinePath);
}

@end
