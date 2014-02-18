#import "Log.h"
#import "IRSignalNameEditViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRHelper.h"

@interface IRSignalNameEditViewController ()

@end

@implementation IRSignalNameEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title = IRLocalizedString(@"Give a name", @"title of IRSignalNameEdit");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                                                           target: self
                                                                                           action: @selector(doneButtonPressed:)];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear: animated];

    // set .signal before viewWillAppear
    _textField.text = _signal.name;

    [self editingChanged: nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear: animated];
}

- (void)processTextField:(id)sender {
    LOG(@"text: %@", _textField.text);

    if (![self isTextValid]) {
        return;
    }

    _signal.name = _textField.text;

    [self.delegate signalNameEditViewController: self
                              didFinishWithInfo: @{
         IRViewControllerResultType: IRViewControllerResultTypeDone,
         IRViewControllerResultText: _textField.text,
         IRViewControllerResultSignal: _signal,
     }];
}

- (BOOL)isTextValid {
    if (!_textField.text) {
        return NO;
    }

    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern: @"^\\s*$"
                                                       options: 0
                                                         error: nil];
    NSUInteger matches = [regex numberOfMatchesInString: _textField.text
                                                options: 0
                                                  range: NSMakeRange(0, _textField.text.length)];

    if (matches > 0) {
        // empty or whitespace only
        return NO;
    }
    return YES;
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning {
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonPressed:(id)selector {
    LOG(@"text: %@", self.textField.text);
    [self processTextField: nil];
}

- (IBAction)editingChanged:(id)sender {
    BOOL valid = [self isTextValid];

    self.navigationItem.rightBarButtonItem.enabled = valid;
    self.textField.textColor = valid ? [IRViewCustomizer textColor] : [IRViewCustomizer inactiveFontColor];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self processTextField: nil];
    return NO;
}

@end
