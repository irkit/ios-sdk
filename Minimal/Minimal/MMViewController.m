#import "Log.h"
#import "MMViewController.h"

@interface MMViewController ()

@end

@implementation MMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _signals = [[IRSignals alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = _signals;

    self.view.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)viewDidAppear:(BOOL)animated {
    LOG_CURRENT_METHOD;
    if (! _peripheral) {
        IRNewPeripheralViewController *vc = [[IRNewPeripheralViewController alloc] init];
        vc.delegate = self;
        [self presentViewController:vc
                           animated:YES
                         completion:^{
                             LOG(@"presented");
                         }];
    }
}

- (IBAction)addButtonTouched:(id)sender {
    if (! _peripheral) {
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

    if (peripheral) {
        _peripheral = peripheral;
    }
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
        [_signals addSignalsObject:signal];
        [self.tableView reloadData];
    }
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 LOG(@"dismissed");
                             }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [IRSignalCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG(@"indexPath: %@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];

    IRSignal *signal = [_signals objectAtIndex:indexPath.row];
    [signal sendWithCompletion:^(NSError *error) {
        LOG(@"sent error: %@", error);
    }];
}

@end
