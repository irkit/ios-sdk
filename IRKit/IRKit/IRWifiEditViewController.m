#import "Log.h"
#import "IRWifiEditViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRKit.h"
#import "IREditCell.h"
#import "IRWifiSecuritySelectViewController.h"

@interface IRWifiEditViewController ()

@end

@implementation IRWifiEditViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title = @"Join Wifi Network";
    // self.navigationItem.hidesBackButton    = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed:)];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);

    NSBundle *main = [NSBundle mainBundle];
    NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                  ofType:@"bundle"]];
    [self.tableView registerNib:[UINib nibWithNibName:@"IREditCell" bundle:resources]
         forCellReuseIdentifier:IRKitCellIdentifierEdit];
}

- (void) viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear:animated];

    // set .peripheral before viewWillAppear
//    _textField.text = _peripheral.customizedName;

    [self editingChanged:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear:animated];
}

- (IBAction) processTextField: (id)sender {
//    LOG( @"text: %@", _textField.text );

//    if (! [self isTextValid]) {
//        return;
//    }

//    _peripheral.customizedName = _textField.text;
    [[IRKit sharedInstance] save];

//    [self.delegate nameEditViewController:self
//                        didFinishWithInfo:@{
//               IRViewControllerResultType: IRViewControllerResultTypeDone,
//         IRViewControllerResultPeripheral: _peripheral,
//               IRViewControllerResultText: _textField.text,
//     }];
}

//- (BOOL) isTextValid {
//    if (! _textField.text) {
//        return NO;
//    }
//
//    NSRegularExpression *regex = [NSRegularExpression
//                                  regularExpressionWithPattern:@"^\\s*$"
//                                  options:nil
//                                  error:nil];
//    NSUInteger matches = [regex numberOfMatchesInString:_textField.text
//                                                options:nil
//                                                  range:NSMakeRange(0,_textField.text.length)];
//
//    if (matches > 0) {
//        // empty or whitespace only
//        return NO;
//    }
//    return YES;
//}

#pragma mark - UI events

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonPressed:(id)selector
{
//    LOG(@"text: %@", self.textField.text);
    [self processTextField:nil];
}

- (IBAction)editingChanged:(id)sender {
//    BOOL valid = [self isTextValid];
//    self.navigationItem.rightBarButtonItem.enabled = valid;
//    self.textField.textColor = valid ? [IRViewCustomizer activeFontColor] : [IRViewCustomizer inactiveFontColor];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [self processTextField:nil];
    return NO;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;

    switch (indexPath.section) {
        case 0:
        {
            IREditCell *cell = (IREditCell*)[tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierEdit];
            cell.titleLabel.text = @"Name";
            cell.editTextField.delegate = self;
            cell.editTextField.placeholder = @"Network Name";
            return cell;
        }
        case 1:
        {
        switch (indexPath.row) {
            case 0:
            {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IRKitWifiEditSecurityCell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"IRKitWifiEditSecurityCell"];
                }
                cell.textLabel.text = @"Security";
                cell.detailTextLabel.text = @"WPA2";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
            case 1:
            {
                IREditCell *cell = (IREditCell*)[tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierEdit];
                cell.titleLabel.text = @"Password";
                cell.editTextField.delegate = self;
                cell.editTextField.placeholder = @"Password";
                return cell;
            }
        }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ( ((indexPath.section == 0) && (indexPath.row == 0)) ||
         ((indexPath.section == 1) && (indexPath.row == 1)) ) {
        IREditCell *cell = (IREditCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell.editTextField becomeFirstResponder];
    }
    else {
        NSBundle *main = [NSBundle mainBundle];
        NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources" ofType:@"bundle"]];
        IRWifiSecuritySelectViewController *c = [[IRWifiSecuritySelectViewController alloc] initWithNibName:@"IRWifiSecuritySelectViewController" bundle:resources];
        c.delegate = self;
        [self.navigationController pushViewController:c animated:YES];
    }
}

#pragma mark - IRWifiSecuritySelectViewControllerDelegate

- (void)securitySelectviewController:(IRWifiSecuritySelectViewController *)viewController didFinishWithSecurityType:(uint8_t)securityType {
    LOG_CURRENT_METHOD;
}

@end
