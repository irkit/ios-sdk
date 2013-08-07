#import "ONImagePickerViewController.h"
#import "ONIconCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>

@interface ONImagePickerViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *iconButton;

@end

@implementation ONImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonTouched:(id)sender {
    LOG_CURRENT_METHOD;
    [self.delegate imagePickerViewController:self
                                didPickImage:nil
                                    withName:nil];
}

- (IBAction)albumButtonTouched:(id)sender {
    LOG_CURRENT_METHOD;
    UIImagePickerController *c = [[UIImagePickerController alloc] init];
    c.delegate = self;
    c.modalPresentationStyle = UIModalPresentationCurrentContext;
    c.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    c.mediaTypes = @[(NSString*)kUTTypeImage];
    c.allowsEditing = YES;
    [self presentViewController:c
                       animated:YES
                     completion:^{
                         LOG( @"presented" );
                     }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    LOG_CURRENT_METHOD;
    [self dismissViewControllerAnimated:YES completion:nil];

    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    [self.delegate imagePickerViewController:self
                                didPickImage:editedImage
                                    withName:@"Original"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    LOG_CURRENT_METHOD;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    LOG( @"highlighted: %@", indexPath );

    ONIconCell *cell = (ONIconCell*)[collectionView viewWithTag:indexPath.row+1];
    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         cell.imageView.alpha = 0.5;
                     }
                     completion:^(BOOL finished){
                     }
     ];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    LOG( @"unhighlighted: %@", indexPath );

    ONIconCell *cell = (ONIconCell*)[collectionView viewWithTag:indexPath.row+1];
    [UIView animateWithDuration:0.4
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         cell.imageView.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                     }
     ];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LOG( @"selected: %@", indexPath );

    ONIconCell *cell = (ONIconCell*)[collectionView viewWithTag:indexPath.row+1];
    [self.delegate imagePickerViewController:self
                                didPickImage:cell.imageView.image
                                    withName:[self icons][ indexPath.row ][ 1 ]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    LOG_CURRENT_METHOD;
    return [self icons].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LOG_CURRENT_METHOD;
    ONIconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IconCell"
                                                                 forIndexPath:indexPath];
    NSString *name = [self icons][ indexPath.row ][ 0 ];
    cell.imageView.image = [UIImage imageNamed: name];
    cell.imageView.layer.cornerRadius = 10.;
    cell.imageView.layer.masksToBounds = YES;
    cell.tag = indexPath.row + 1;
    return cell;
}

#pragma mark -

- (NSArray*) icons {
    return @[
             @[ @"icon_power.png",     @"Power" ],
             @[ @"icon_tv.png",        @"TV" ],
             @[ @"icon_aircon.png",    @"Air" ],
             @[ @"icon_fan.png",       @"Fan" ],
             @[ @"icon_light.png",     @"Light" ],
             @[ @"icon_time.png",      @"Time" ],
             @[ @"icon_eject.png",     @"Eject" ],
             @[ @"icon_left_01.png",   @"Left 1" ],
             @[ @"icon_left_02.png",   @"Left 2" ],
             @[ @"icon_right_01.png",  @"Right 1" ],
             @[ @"icon_right_02.png",  @"Right 2" ],
             @[ @"icon_rewind.png",    @"Rewind" ],
             @[ @"icon_prev.png",      @"Prev" ],
             @[ @"icon_play.png",      @"Play" ],
             @[ @"icon_pause.png",     @"Pause" ],
             @[ @"icon_playpause.png", @"Pause 2" ],
             @[ @"icon_recording.png", @"Record" ],
             @[ @"icon_stop.png",      @"Stop" ],
             @[ @"icon_next.png",      @"Next" ],
             @[ @"icon_ff.png",        @"FF" ],
             @[ @"icon_top_01.png",    @"Up 1" ],
             @[ @"icon_top_02.png",    @"Up 2" ],
             @[ @"icon_up.png",        @"Up 3" ],
             @[ @"icon_bottom_01.png", @"Down 1" ],
             @[ @"icon_bottom_02.png", @"Down 2" ],
             @[ @"icon_down.png",      @"Down 3" ],
             @[ @"icon_pluss.png",     @"Plus" ],
             @[ @"icon_minus.png",     @"Minus" ],
             @[ @"icon_0.png",         @"0" ],
             @[ @"icon_1.png",         @"1" ],
             @[ @"icon_2.png",         @"2" ],
             @[ @"icon_3.png",         @"3" ],
             @[ @"icon_4.png",         @"4" ],
             @[ @"icon_5.png",         @"5" ],
             @[ @"icon_6.png",         @"6" ],
             @[ @"icon_7.png",         @"7" ],
             @[ @"icon_8.png",         @"8" ],
             @[ @"icon_9.png",         @"9" ],
             @[ @"icon_10.png",        @"10" ],
             @[ @"icon_11.png",        @"11" ],
             @[ @"icon_12.png",        @"12" ],
             ];
}

@end
