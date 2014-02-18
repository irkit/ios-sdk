#import "Log.h"
#import "IRWifiSecuritySelectViewController.h"
#import "IRConst.h"
#import "IRViewCustomizer.h"
#import "IRKit.h"
#import "IREditCell.h"

@interface IRWifiSecuritySelectViewController ()

@end

@implementation IRWifiSecuritySelectViewController

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

    self.title = @"Security";
    self.navigationItem.rightBarButtonItem = nil;

    [IRViewCustomizer sharedInstance].viewDidLoad(self);
}

- (enum IRSecurityType)securityTypeForRow:(NSUInteger)row {
    enum IRSecurityType ret;

    switch (row) {
    case 0:
        ret = IRSecurityTypeNone;
        break;
    case 1:
        ret = IRSecurityTypeWEP;
        break;
    case 2:
    default:
        ret = IRSecurityTypeWPA2;
        break;
    }
    return ret;
}

- (NSUInteger)rowForSecurityType:(enum IRSecurityType)type {
    NSUInteger ret;

    switch (type) {
    case IRSecurityTypeNone:
        ret = 0;
        break;
    case IRSecurityTypeWEP:
        ret = 1;
        break;
    case IRSecurityTypeWPA2:
        ret = 2;
        break;
    }
    return ret;
}

- (void)viewWillAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    [super viewWillDisappear: animated];

    [_delegate securitySelectviewController: self
                  didFinishWithSecurityType: _selectedSecurityType];
}

#pragma mark - UI events

- (void)didReceiveMemoryWarning {
    LOG_CURRENT_METHOD;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"IRWifiSecuritySelectCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier: @"IRWifiSecuritySelectCell"];
    }

    enum IRSecurityType security = [self securityTypeForRow: indexPath.row];
    cell.textLabel.text = [IRKeys securityTypeStringOf: security];

    if ([self securityTypeForRow: indexPath.row] == _selectedSecurityType) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath: indexPath animated: YES];

    NSUInteger row = [self rowForSecurityType: _selectedSecurityType];

    _selectedSecurityType = [self securityTypeForRow: indexPath.row];

    if (indexPath.row != row) {
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow: row inSection: 0], indexPath];
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths: indexPaths withRowAnimation: UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

@end
