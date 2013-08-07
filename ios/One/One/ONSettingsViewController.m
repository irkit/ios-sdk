#import "ONSettingsViewController.h"
#import <BlocksKit/BlocksKit.h>

#define kAppStoreURLTemplate @"itms-apps://itunes.apple.com/app/id%@"

@interface ONSettingsViewController ()

@end

@implementation ONSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    LOG_CURRENT_METHOD;
    [super viewDidLoad];

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
#ifdef DEBUG
    version = [NSString stringWithFormat:@"%@ DEBUG",version];
#endif
    version = [NSString stringWithFormat:@"Version: %@",version];
    [_versionButton setTitle:version
                    forState:UIControlStateNormal];
    [_versionButton setTitle:version
                    forState:UIControlStateHighlighted];

    self.tableView.backgroundView = nil;
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonTouched:(id)sender {
    LOG_CURRENT_METHOD;
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 LOG(@"dismissed");
                             }];
}

- (IBAction)versionButtonTouched:(id)sender {
    LOG_CURRENT_METHOD;

    // TODO fix app id
    NSString *url = [NSString stringWithFormat:kAppStoreURLTemplate, @"xxxxxxxxxxxxxx"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark - IRPeripheralNameEditViewControllerDelegate

- (void)nameEditViewController:(IRPeripheralNameEditViewController *)viewController
             didFinishWithInfo:(NSDictionary*)info {
    LOG( @"info: %@", info );

    [self.navigationController popViewControllerAnimated:YES];

    if ([info[IRViewControllerResultType] isEqualToString:IRViewControllerResultTypeDone]) {
        [self.tableView reloadData];
    }
}

#pragma mark - IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRNewPeripheralViewController *)viewController
            didFinishWithPeripheral:(IRPeripheral *)peripheral {
    LOG( @"peripheral: %@", peripheral );

    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 LOG( @"dismissed" );
                             }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [[IRKit sharedInstance].peripherals tableView:self.tableView
                                           numberOfRowsInSection:0] + 1;
        case 1:
            return 3;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;

    UITableViewCell *cell;

    switch (indexPath.section) {
        case 0:
            if ([IRKit sharedInstance].numberOfPeripherals <= indexPath.row) {
                // last line is always "+ Add New Peripheral"
                cell = [tableView dequeueReusableCellWithIdentifier:@"NewPeripheralCell"];
                cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
                cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
                break;
            }
            cell = [[IRKit sharedInstance].peripherals tableView:tableView
                                           cellForRowAtIndexPath:indexPath];
            cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Help"];
                    cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
                    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
                    return cell;
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Opensource"];
                    cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
                    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
                    return cell;
                case 2:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Buydevice"];
                    cell.backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
                    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
                    return cell;
            }
            break;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_CURRENT_METHOD;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
        {
            if ([IRKit sharedInstance].numberOfPeripherals <= indexPath.row) {
                // pressed Add New Peripheral cell
                IRNewPeripheralViewController *c = [[IRNewPeripheralViewController alloc] init];
                c.delegate = (id<IRNewPeripheralViewControllerDelegate>)self;
                [self presentViewController:c
                                   animated:YES
                                 completion:^{
                    LOG( @"presented" );
                }];
                return;
            }
            IRPeripheral *peripheral = [[IRKit sharedInstance].peripherals objectAtIndex: indexPath.row];
            UIActionSheet *sheet = [UIActionSheet actionSheetWithTitle:@""];
            [sheet addButtonWithTitle:@"Edit Name" handler:^{
                NSBundle *main = [NSBundle mainBundle];
                NSBundle *resources = [NSBundle bundleWithPath:[main pathForResource:@"IRKitResources"
                                                                              ofType:@"bundle"]];
                IRPeripheralNameEditViewController *c = [[IRPeripheralNameEditViewController alloc] initWithNibName:@"IRPeripheralNameEditViewController"
                                                                                                               bundle:resources];
                c.delegate = self;
                c.peripheral = peripheral;
                [self.navigationController pushViewController:c
                                                     animated:YES];
            }];
            [sheet setCancelButtonWithTitle:nil handler:^{
                LOG( @"canceled" );
            }];
            [sheet showInView:self.view];
            break;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    IRWebViewController *c = [[IRWebViewController alloc] init];
                    c.url = @"http://irkit.github.com/";
                    c.title = @"Help";
                    [self.navigationController pushViewController:c
                                                         animated:YES];
                    break;
                }
                case 1:
                {
                    IRWebViewController *c = [[IRWebViewController alloc] init];
                    c.url = @"http://github.com/irkit";
                    c.title = @"Opensource";
                    [self.navigationController pushViewController:c
                                                         animated:YES];
                    break;
                }
                case 2:
                {
                    IRWebViewController *c = [[IRWebViewController alloc] init];
                    c.url = @"http://www.amazon.co.jp/s/field-keywords=irkit";
                    c.title = @"Buy Peripheral";
                    [self.navigationController pushViewController:c
                                                         animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    switch (indexPath.section) {
        case 0:
        {
            if ([IRKit sharedInstance].numberOfPeripherals <= indexPath.row) {
                return 44.;
            }
            return [[IRKit sharedInstance].peripherals tableView:tableView
                                         heightForRowAtIndexPath:indexPath];
        }
        default:
            break;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    switch (section) {
        case 0:
            return 40;
        case 1:
            return 16;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    switch (section) {
        case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsHeader1"];
            return cell;
        }
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsHeader2"];
            return cell;
        }
        default:
            break;
    }
    return nil;
}

@end
