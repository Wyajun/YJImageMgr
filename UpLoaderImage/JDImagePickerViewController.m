//
//  WyjImagePicker.m
//  XTBrowser
//
//  Created by 王亚军 on 14-2-24.
//  Copyright (c) 2014年 scanvir. All rights reserved.
//

#import "JDImagePickerViewController.h"
@interface JDImagePickerViewController() <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(nonatomic,strong)UIImagePickerController *imgPick;
@property(nonatomic)BOOL edit;
@property(nonatomic)imagePickType type;
@property(nonatomic,copy)PickerCompletionBlock pickerCompletionBlock;
@property(nonatomic)CGRect defaultFrame;
@property(nonatomic)CGRect coustomFrame;
@property(nonatomic,weak)UIViewController *push;
@property(nonatomic)BOOL isShow; //标记图片控制器是否弹出
@property(nonatomic)BOOL isCamera; // 标记当前控制器是拍照
@end


@implementation JDImagePickerViewController

+(instancetype)shareImagePickerViewController {
    static JDImagePickerViewController *_share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share = [[JDImagePickerViewController alloc] initSuper];
    });
    return _share;
}
-(instancetype)initSuper
{
    self = [super init];
    _imgPick = [[UIImagePickerController alloc] init];
    _imgPick.delegate = self;
    
    return self;
}
-(void)presentViewController:(UIViewController *)viewControllerToPresent imagePickType:(imagePickType)type completion:(PickerCompletionBlock)completion edit:(BOOL)edit {
    _pickerCompletionBlock = completion;
    self.push = viewControllerToPresent;
    self.edit = edit;
    _type = type;
    self.isShow = YES;
//    self.imgPick.allowsEditing = edit;
    switch (type) {
        case imageFromCamera:
           [self pickerCamera:viewControllerToPresent];
            break;
        case imageFromLibrary:
            [self pickerPhotoLibrary:viewControllerToPresent];
            break;
        default:
            break;
    }
}
-(void)presentViewController:(UIViewController *)viewControllerToPresent imagePickType:(imagePickType)type completion:(PickerCompletionBlock)completion frame:(CGRect)frame {
    _pickerCompletionBlock = completion;
    self.edit = YES;
    self.coustomFrame = frame;
    self.push = viewControllerToPresent;
    _type = type;
    self.isShow = YES;
    switch (type) {
        case imageFromCamera:
            [self pickerCamera:viewControllerToPresent];
            break;
        case imageFromLibrary:
            [self pickerPhotoLibrary:viewControllerToPresent];
            break;
        default:
            break;
    }
}
- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image ;
    image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (self.edit) {
        UINavigationController *vc = aPicker;
        if (self.type == imageFromCamera) {
            [aPicker dismissViewControllerAnimated:NO completion:nil];
            vc = self.push.navigationController;
            self.isCamera = NO;
        }
        CGRect rect = self.coustomFrame.size.height > 10 ? self.coustomFrame:self.defaultFrame;
    }else {
        if (self.pickerCompletionBlock) {
            self.pickerCompletionBlock(image);
        }
        [aPicker dismissViewControllerAnimated:YES completion:nil];
        self.isShow = NO;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)aPicker {
    [aPicker dismissViewControllerAnimated:YES completion:nil];
    self.isShow = NO;
}
- (void) pickerCamera:(UIViewController *)vc
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _imgPick.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imgPick.delegate = self;
        [vc presentViewController:_imgPick animated:YES completion:nil];
        self.isCamera = YES;
    }else
    {
        //出错提示
    }
}

- (void) pickerPhotoLibrary:(UIViewController *)vc
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        _imgPick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imgPick.delegate = self;
        [vc presentViewController:_imgPick animated:YES completion:nil];
        self.isCamera = NO;
    }else
    {
        //出错提示
    }
}
#pragma --mark --vip
//-(void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
//    if (self.pickerCompletionBlock) {
//        self.pickerCompletionBlock(editedImage);
//    }
//    if (self.type == imageFromLibrary) {
//        [self.imgPick dismissViewControllerAnimated:YES completion:nil];
//    }else {
//        [self.push.navigationController popViewControllerAnimated:YES];
//    }
//    self.isShow = NO;
//}
//-(void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
//    [cropperViewController.navigationController popViewControllerAnimated:YES];
//    if (self.type == imageFromCamera) {
//        self.isShow = NO;
//    }
//}
#pragma --mark

-(BOOL)disMissImagePickerViewController {
    if (!self.isShow) {
        return NO;
    }
    if (self.type == imageFromCamera && !self.isCamera) {
        return NO;// 为了动画
    }else {
        [self.imgPick dismissViewControllerAnimated:YES completion:nil ];
    }
    return YES;
}
-(BOOL)imageEdit {
    return _isShow;
}
@end
