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

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation IRMorsePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LOG_CURRENT_METHOD;
    _player = [[IRMorsePlayerOperationQueue alloc] init];
}

- (void) processTextField: (id) sender {
    LOG(@"text: %@", _textField.text);

    [_player addOperation: [IRMorsePlayerOperation playMorseFromString:_textField.text
                                                         withWordSpeed:@13]];
    _textField.text = @"";
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    LOG_CURRENT_METHOD;
    [self processTextField:nil];
    return NO;
}

@end
