//
//  IRChartView.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/05/21.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import "IRChartView.h"

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

-(void)drawInContext:(CGContextRef)context
{
    // Drawing with a white stroke color
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    // Drawing with a b lue fill color
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);

    CGPoint center;

    // Add a star to the current path
    center = CGPointMake(90.0, 90.0);
    CGContextMoveToPoint(context, center.x, center.y + 60.0);
    for(int i = 1; i < 5; ++i)
    {
        CGFloat x = 60.0 * sinf(i * 4.0 * M_PI / 5.0);
        CGFloat y = 60.0 * cosf(i * 4.0 * M_PI / 5.0);
        CGContextAddLineToPoint(context, center.x + x, center.y + y);
    }
    // And close the subpath.
    CGContextClosePath(context);

    // Now draw the star & hexagon with the current drawing mode.
    CGContextDrawPath(context, kCGPathFill);
}

@end
