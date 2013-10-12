//
//  IRMorsePlayerViewController.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/10/08.
//
//

#import "Log.h"
#import "IRMorsePlayerViewController.h"
#import "IRMorsePlayerOperation.h"
#import "IRMorsePlayerOperationQueue.h"

@interface IRMorsePlayerViewController ()

@property (nonatomic) IRMorsePlayerOperationQueue *player;

@property (weak, nonatomic) IBOutlet UITextField *wpmField;
@property (weak, nonatomic) IBOutlet UITextField *messageField;

@end

@implementation IRMorsePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LOG_CURRENT_METHOD;
    _player = [[IRMorsePlayerOperationQueue alloc] init];
}

- (void) processTextField: (id) sender {
    if (sender == _messageField) {
        NSString *message = _messageField.text;
        LOG(@"text: %@", message);

        NSNumber *wpm = [[[NSNumberFormatter alloc] init] numberFromString: _wpmField.text];
        LOG(@"wpm: %@", wpm);

        [_player addOperation: [IRMorsePlayerOperation playMorseFromString:message
                                                             withWordSpeed:wpm]];
    }
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    LOG_CURRENT_METHOD;
    [self processTextField:textField];
    return NO;
}

@end
