//
//  WyjImagePicker.h
//  XTBrowser
//
//  Created by 王亚军 on 14-2-24.
//  Copyright (c) 2014年 scanvir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^PickerCompletionBlock) (UIImage *);
typedef NS_ENUM(NSInteger, imagePickType)
{
    imageFromLibrary,
    imageFromCamera,
    imageFramLibraryorCamera
};

@interface JDImagePickerViewController : NSObject
@property(nonatomic,readonly)BOOL imageEdit;
+(instancetype)shareImagePickerViewController;
-(void)presentViewController:(UIViewController *)viewControllerToPresent imagePickType:(imagePickType)type completion:(PickerCompletionBlock)completion edit:(BOOL)edit;

-(void)presentViewController:(UIViewController *)viewControllerToPresent imagePickType:(imagePickType)type completion:(PickerCompletionBlock)completion frame:(CGRect)frame;
// 解决跳转bug 待解未完成
-(BOOL)disMissImagePickerViewController;

@end
