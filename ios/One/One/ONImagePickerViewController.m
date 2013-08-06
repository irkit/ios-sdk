//
//  ONImagePickerViewController.m
//  One
//
//  Created by Masakazu Ohtsuka on 2013/08/05.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

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
                                didPickImage:nil];
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
                                didPickImage:editedImage];
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
                                didPickImage:cell.imageView.image];
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
    NSString *name = [self icons][ indexPath.row ];
    cell.imageView.image = [UIImage imageNamed: name];
    cell.imageView.layer.cornerRadius = 10.;
    cell.imageView.layer.masksToBounds = YES;
    cell.tag = indexPath.row + 1;
    return cell;
}

#pragma mark -

- (NSArray*) icons {
    return @[
             @"icon_power.png",
             @"icon_tv.png",
             @"icon_aircon.png",
             @"icon_fan.png",
             @"icon_light.png",
             @"icon_time.png",
             @"icon_eject.png",
             @"icon_left_01.png",
             @"icon_left_02.png",
             @"icon_right_01.png",
             @"icon_right_02.png",
             @"icon_rewind.png",
             @"icon_prev.png",
             @"icon_pause.png",
             @"icon_play.png",
             @"icon_playpause.png",
             @"icon_recording.png",
             @"icon_stop.png",
             @"icon_next.png",
             @"icon_ff.png",
             @"icon_top_01.png",
             @"icon_top_02.png",
             @"icon_up.png",
             @"icon_bottom_01.png",
             @"icon_bottom_02.png",
             @"icon_down.png",
             @"icon_pluss.png",
             @"icon_minus.png",
             @"icon_0.png",
             @"icon_1.png",
             @"icon_2.png",
             @"icon_3.png",
             @"icon_4.png",
             @"icon_5.png",
             @"icon_6.png",
             @"icon_7.png",
             @"icon_8.png",
             @"icon_9.png",
             @"icon_10.png",
             @"icon_11.png",
             @"icon_12.png",
             ];
}

@end
