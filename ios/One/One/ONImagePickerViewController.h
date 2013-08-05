//
//  ONImagePickerViewController.h
//  One
//
//  Created by Masakazu Ohtsuka on 2013/08/05.
//  Copyright (c) 2013年 KAYAC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ONImagePickerViewControllerDelegate;

@interface ONImagePickerViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, assign) id<ONImagePickerViewControllerDelegate> delegate;

@end

@protocol ONImagePickerViewControllerDelegate <NSObject>

@required
- (void)imagePickerViewController:(ONImagePickerViewController*)viewController
                     didPickImage:(UIImage*)image;

@end
