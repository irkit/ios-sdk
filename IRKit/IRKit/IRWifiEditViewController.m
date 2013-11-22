#import "Log.h"
#import "IRWifiEditViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRKit.h"
#import "IREditCell.h"
#import "IRWifiSecuritySelectViewController.h"
#import "IRKeys.h"
#import "IRHelper.h"

#define TAG_SSID_CELL          1
#define TAG_PASSWORD_CELL      2
#define TAG_PASSWORD_TEXTFIELD 3

@interface IRWifiEditViewController ()

@property (nonatomic) IRKeys* keys;

@end

@implementation IRWifiEditViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _keys = [[IRKeys alloc] init];
        // TODO load from keychain for sane defaults
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title = @"Join Wifi Network";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed:)];

    [IRViewCustomizer sharedInstance].viewDidLoad(self);

    [self.tableView registerNib:[UINib nibWithNibName:@"IREditCell" bundle:[IRHelper resources]]
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

- (BOOL) processForm {
    IREditCell* ssidCell = (IREditCell*)[self.view viewWithTag:TAG_SSID_CELL];
    NSString* ssid = ssidCell.editTextField.text;
    LOG( @"ssid: %@", ssid );

    IREditCell* passwordCell = (IREditCell*)[self.view viewWithTag:TAG_PASSWORD_CELL];
    NSString* password = passwordCell.editTextField.text;
    LOG( @"password: %@", password );

    if (! [IRKeys isPassword:password validForSecurityType:_keys.security]) {
        return false;
    }

    _keys.ssid     = ssid;
    _keys.password = password;
    // _keys.security is set in delegate method

    [self.delegate wifiEditViewController:self
                        didFinishWithInfo:@{
               IRViewControllerResultType: IRViewControllerResultTypeDone,
               IRViewControllerResultKeys: _keys,
     }];
    return YES;
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning
{
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonPressed:(id)selector {
    LOG_CURRENT_METHOD;
    [self processForm];
}

- (IBAction)editingChanged:(id)sender {
//    BOOL valid = [self isTextValid];
//    self.navigationItem.rightBarButtonItem.enabled = valid;
//    self.textField.textColor = valid ? [IRViewCustomizer activeFontColor] : [IRViewCustomizer inactiveFontColor];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    LOG_CURRENT_METHOD;
    if (textField.tag == TAG_PASSWORD_TEXTFIELD) {
        if ([self processForm]) {
            return YES;
        }
    }
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
            cell.editTextField.text = _keys.ssid;
            cell.tag = TAG_SSID_CELL;
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
                cell.detailTextLabel.text = _keys.securityTypeString;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
            case 1:
            {
                IREditCell *cell = (IREditCell*)[tableView dequeueReusableCellWithIdentifier:IRKitCellIdentifierEdit];
                cell.titleLabel.text = @"Password";
                cell.editTextField.delegate = self;
                cell.editTextField.placeholder = @"Password";
                cell.editTextField.text = _keys.password;
                cell.editTextField.returnKeyType = UIReturnKeyDone;
                cell.editTextField.tag = TAG_PASSWORD_TEXTFIELD;
                cell.tag = TAG_PASSWORD_CELL;
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
        c.selectedSecurityType = _keys.security;
        [self.navigationController pushViewController:c animated:YES];
    }
}

#pragma mark - IRWifiSecuritySelectViewControllerDelegate

- (void)securitySelectviewController:(IRWifiSecuritySelectViewController *)viewController didFinishWithSecurityType:(enum IRSecurityType)securityType {
    LOG_CURRENT_METHOD;
    _keys.security = securityType;

    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:1]];
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

@end
