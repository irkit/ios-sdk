#import "ONIconCell.h"

@implementation ONIconCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}
*/

- (IBAction)touchDown:(id)sender {
    LOG_CURRENT_METHOD;

    [UIView animateWithDuration:0.5
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         NSLog(@"animation start");
                         //[cell setBackgroundColor:[UIColor colorWithRed: 180.0/255.0 green: 238.0/255.0 blue:180.0/255.0 alpha: 1.0]];
                         self.imageView.alpha = 0.5;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"animation end");
                         //[cell setBackgroundColor:[UIColor whiteColor]];
                         self.imageView.alpha = 0.5;
                     }
     ];
}

- (IBAction)touchUpInside:(id)sender {
    LOG_CURRENT_METHOD;
}

- (IBAction)touchOthers:(id)sender {
    LOG_CURRENT_METHOD;
    self.imageView.alpha = 1.0;
}

@end
