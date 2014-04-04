#import "Log.h"
#import "IRPeripheralCell.h"
#import "IRHTTPClient.h"
#import "IRHTTPClient+UIKit.h"
#import <QuartzCore/QuartzCore.h>

@interface IRPeripheralCell ()

@end

@implementation IRPeripheralCell

- (void)awakeFromNib {
    LOG_CURRENT_METHOD;
    [super awakeFromNib];

    self.iconView.layer.cornerRadius  = 6.;
    self.iconView.layer.masksToBounds = YES;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [_peripheral removeObserver: self
                     forKeyPath: @"peripheral"];
}

- (void)setPeripheral:(IRPeripheral *)peripheral {
    LOG(@"peripheral: %@", peripheral);

    if (_peripheral) {
        // don't double addObserver, nor removeObserver before addObserver
        [_peripheral removeObserver: self
                         forKeyPath: @"peripheral"];
    }
    _peripheral = peripheral;

    self.nameLabel.text   = peripheral.customizedName;
    self.detailLabel.text = self.detailLabelText;

    // load image from internet
    NSString *url = _peripheral.iconURL;
    [IRHTTPClient loadImage: url
          completionHandler:^(NSHTTPURLResponse *response, UIImage *image, NSError *error) {
        if (error || (response.statusCode != 200) || !image) {
            return;
        }
        self.iconView.image = image;
    }];

    [_peripheral addObserver: self
                  forKeyPath: @"peripheral"
                     options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context: NULL];
}

- (NSString *)detailLabelText {
    return [NSString stringWithFormat: @"%@ %@", _peripheral.hostname, _peripheral.modelNameAndRevision];
}

+ (CGFloat)height {
    return 58;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    LOG(@"keyPath: %@", keyPath);

    dispatch_async(dispatch_get_main_queue(), ^{
        self.nameLabel.text = _peripheral.customizedName;
        self.detailLabel.text = self.detailLabelText;
        [self setNeedsDisplay];
    });
}

@end
