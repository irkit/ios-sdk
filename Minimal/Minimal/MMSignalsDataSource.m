#import "MMSignalsDataSource.h"

@interface MMSignalsDataSource ()

@property (nonatomic) IRSignals *signals;

@end

@implementation MMSignalsDataSource

- (instancetype) init {
    self = [super init];
    if (! self) { return nil; }

    _signals = [[IRSignals alloc] init];

    return self;
}

#pragma mark - IRSignals delegate

- (void)addSignalsObject: (IRSignal*) signal {
    [_signals addSignalsObject:signal];
}

- (IRSignal*)objectAtIndex: (NSUInteger) index {
    return [_signals objectAtIndex:index];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_signals countOfSignals];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MMSignalCell"];
    IRSignal *signal = [_signals objectAtIndex:indexPath.row];
    cell.textLabel.text = signal.name;
    return cell;
}

@end
