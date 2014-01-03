#import "Log.h"
#import "MMViewController.h"
#import "MMSignalsDataSource.h"

@interface MMViewController ()

@property (nonatomic) MMSignalsDataSource *datasource;

@end

@implementation MMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _datasource = [[MMSignalsDataSource alloc] init];

    self.tableView.delegate = self;
    self.tableView.dataSource = _datasource;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    static bool did_show = false;
    if ( ([IRKit sharedInstance].countOfReadyPeripherals == 0) && ! did_show) {
        IRNewPeripheralViewController *vc = [[IRNewPeripheralViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             LOG(@"presented");
                         }];
        did_show = true;
    }
}

- (IBAction)addButtonTouched:(id)sender {
    if ( [IRKit sharedInstance].countOfReadyPeripherals == 0 ) {
        IRNewPeripheralViewController *vc = [[IRNewPeripheralViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             LOG(@"presented");
                         }];
    }
    else {
        IRNewSignalViewController *vc = [[IRNewSignalViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             LOG(@"presented");
                         }];
    }
}

#pragma mark - IRNewPeripheralViewControllerDelegate

- (void)newPeripheralViewController:(IRNewPeripheralViewController *)viewController
            didFinishWithPeripheral:(IRPeripheral *)peripheral {
    LOG( @"peripheral: %@", peripheral );

    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 LOG(@"dismissed");
                             }];
}

#pragma mark - IRNewSignalViewControllerDelegate

- (void)newSignalViewController:(IRNewSignalViewController *)viewController
            didFinishWithSignal:(IRSignal *)signal {
    LOG( @"signal: %@", signal );

    if (signal) {
        [_datasource addSignalsObject:signal];
        [self.tableView reloadData];
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 LOG(@"dismissed");
                             }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG(@"indexPath: %@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];

    IRSignal *signal = [_datasource objectAtIndex:indexPath.row];
    [signal sendWithCompletion:^(NSError *error) {
        LOG(@"sent error: %@", error);
    }];
}

@end
