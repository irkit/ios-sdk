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

static NSString *ssidCache = nil;

@interface IRWifiEditViewController ()

@end

@implementation IRWifiEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    LOG_CURRENT_METHOD;
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    self.title                             = IRLocalizedString(@"Join Wi-Fi Network", @"title of IRWifiEdit");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                                                           target: self
                                                                                           action: @selector(doneButtonPressed:)];

    self.tableView.backgroundView  = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    [IRViewCustomizer sharedInstance].viewDidLoad(self);

    [IREditCell class];
    [self.tableView registerNib: [UINib nibWithNibName: @"IREditCell" bundle: [IRHelper resources]]
         forCellReuseIdentifier: IRKitCellIdentifierEdit];
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear: animated];

    [self editingChanged: nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear: animated];
}

- (BOOL)processForm {
    IREditCell *ssidCell = (IREditCell *)[self.view viewWithTag: TAG_SSID_CELL];
    NSString *ssid       = ssidCell.editTextField.text;

    LOG(@"ssid: %@", ssid);

    IREditCell *passwordCell = (IREditCell *)[self.view viewWithTag: TAG_PASSWORD_CELL];
    NSString *password       = passwordCell.editTextField.text;
    LOG(@"password: %@", password);

    if (!ssid.length) {
        return false;
    }

    if (![IRKeys isPassword: password validForSecurityType: _keys.security]) {
        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"Password Invalid", @"alert title in IRWifiEditViewController")
                                    message: nil
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [passwordCell becomeFirstResponder];
        return false;
    }
    if ([ssid rangeOfString: @","].location != NSNotFound) {
        // if "," exists in ssid
        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"SSID and Password can't include \",\" please change your Wi-Fi settings", @"alert title in IRWifiEditViewController")
                                    message: nil
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [ssidCell becomeFirstResponder];
        return false;
    }
    if ([ssid rangeOfString: @"IRKit" options: NSCaseInsensitiveSearch|NSAnchoredSearch].location != NSNotFound) {
        // I bet your home wi-fi network name doesn't start with "IRKit"
        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"Input your HOME Wi-Fi information", @"alert title to input HOME Wi-Fi information in IRWifiEditViewController")
                                    message: nil
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [ssidCell becomeFirstResponder];
        return false;
    }
    if ([password rangeOfString: @","].location != NSNotFound) {
        // if "," exists in password
        [[[UIAlertView alloc] initWithTitle: IRLocalizedString(@"SSID and Password can't include \",\" please change your Wi-Fi settings", @"alert title in IRWifiEditViewController")
                                    message: nil
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [passwordCell becomeFirstResponder];
        return false;
    }

    ssidCache = [ssid copy];

    _keys.ssid     = ssid;
    _keys.password = password;
    // _keys.security is set in delegate method

    [self.delegate wifiEditViewController: self
                        didFinishWithInfo: @{
         IRViewControllerResultType: IRViewControllerResultTypeDone,
         IRViewControllerResultKeys: _keys,
     }];
    return YES;
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning {
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
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
        IREditCell *cell = (IREditCell *)[tableView dequeueReusableCellWithIdentifier: IRKitCellIdentifierEdit];
        cell.titleLabel.text                      = IRLocalizedString(@"Name", @"wifi network name");
        cell.editTextField.delegate               = self;
        cell.editTextField.placeholder            = IRLocalizedString(@"Network Name", @"wifi network name placeholder");
        cell.editTextField.text                   = _keys.ssid;
        cell.editTextField.keyboardType           = UIKeyboardTypeASCIICapable;
        cell.editTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        cell.editTextField.autocorrectionType     = UITextAutocorrectionTypeNo;
        cell.tag                                  = TAG_SSID_CELL;

        if (ssidCache) {
            cell.editTextField.text = ssidCache;
        }
        else {
            NSString *ssid = [IRHelper currentWifiSSID];
            if ([ssid rangeOfString: @"IRKit" options: NSCaseInsensitiveSearch|NSAnchoredSearch].location != NSNotFound) {
                // if we're connected to a network name starting with "IRKit", ignore it.
                cell.editTextField.text = @"";
            }
            else {
                cell.editTextField.text = ssid;
            }
        }

        return cell;
    }
    case 1:
    {
        switch (indexPath.row) {
        case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"IRKitWifiEditSecurityCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @"IRKitWifiEditSecurityCell"];
            }
            cell.textLabel.text       = IRLocalizedString(@"Security", @"security level");
            cell.detailTextLabel.text = _keys.securityTypeString;
            cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case 1:
        {
            IREditCell *cell = (IREditCell *)[tableView dequeueReusableCellWithIdentifier: IRKitCellIdentifierEdit];
            cell.titleLabel.text                      = IRLocalizedString(@"Password", @"wifi password");
            cell.editTextField.delegate               = self;
            cell.editTextField.placeholder            = @"";
            cell.editTextField.text                   = _keys.password;
            cell.editTextField.returnKeyType          = UIReturnKeyDone;
            cell.editTextField.tag                    = TAG_PASSWORD_TEXTFIELD;
            cell.editTextField.keyboardType           = UIKeyboardTypeASCIICapable;
            cell.editTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.editTextField.autocorrectionType     = UITextAutocorrectionTypeNo;
            cell.tag                                  = TAG_PASSWORD_CELL;
            return cell;
        }
        }
    }
    }
    return nil;
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
    return 0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath: indexPath animated: YES];

    if ( ((indexPath.section == 0) && (indexPath.row == 0)) ||
         ((indexPath.section == 1) && (indexPath.row == 1)) )
    {
        IREditCell *cell = (IREditCell *)[tableView cellForRowAtIndexPath: indexPath];
        [cell.editTextField becomeFirstResponder];
    }
    else {
        IRWifiSecuritySelectViewController *c = [[IRWifiSecuritySelectViewController alloc] initWithNibName: @"IRWifiSecuritySelectViewController" bundle: [IRHelper resources]];
        c.delegate             = self;
        c.selectedSecurityType = _keys.security;
        [self.navigationController pushViewController: c animated: YES];
    }
}

#pragma mark - IRWifiSecuritySelectViewControllerDelegate

- (void)securitySelectviewController:(IRWifiSecuritySelectViewController *)viewController didFinishWithSecurityType:(enum IRSecurityType)securityType {
    LOG_CURRENT_METHOD;
    _keys.security = securityType;

    NSArray *indexPaths = @[[NSIndexPath indexPathForRow: 0 inSection: 1]];
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths: indexPaths withRowAnimation: UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

@end
