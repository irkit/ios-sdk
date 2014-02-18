#import "Log.h"
#import "IRPeripheralNameEditViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRKit.h"
#import "IRHelper.h"

@interface IRPeripheralNameEditViewController ()

@end

@implementation IRPeripheralNameEditViewController

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

    self.title = IRLocalizedString(@"Give a name", @"title of IRPeripheralNameEdit");
    self.navigationItem.hidesBackButton    = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                                                           target: self
                                                                                           action: @selector(doneButtonPressed:)];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear: animated];

    // set .peripheral before viewWillAppear
    _textField.text = _peripheral.customizedName;

    [self editingChanged: nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear: animated];
}

- (IBAction)processTextField:(id)sender {
    LOG(@"text: %@", _textField.text);

    if (![self isTextValid]) {
        return;
    }

    _peripheral.customizedName = _textField.text;
    [[IRKit sharedInstance] save];

    [self.delegate nameEditViewController: self
                        didFinishWithInfo: @{
         IRViewControllerResultType: IRViewControllerResultTypeDone,
         IRViewControllerResultPeripheral: _peripheral,
         IRViewControllerResultText: _textField.text,
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
