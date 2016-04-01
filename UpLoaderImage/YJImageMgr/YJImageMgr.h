//
//  YJImageMgr.h
//  UpLoaderImage
//
//  Created by 王亚军 on 16/3/23.
//  Copyright © 2016年 王亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface YJImageMgr : NSObject
+(instancetype)shareImageMgr;
/*
 * 修正图片显示方向不正确问题
 */
+ (UIImage *)fixOrientation:(UIImage *)image;
/*
 * max : 单位 M
 */
+(NSData *)fixImage:(UIImage *)image MaxSize:(CGFloat)max;
@end

@interface YJImageMgr (upLoaderImage)
/**
 *  压缩上传图片
 *
 *  @param upImage 要压缩的图片
 *
 *  @return 压缩后的图片数据
 */
-(NSData *)upLoaderDataWithImage:(UIImage *)upImage;
@end


@interface YJImageMgr (ResoureImage)
/**
 *  获取资源图片 此方法会拦截系统imageNamed方法
 *  优先获取xcassets之外的图片
 *  @param imageName 图片名称
 *
 *  @return 对应的图片
 */
+(UIImage *)imageName:(NSString *)imageName;
/**
 *  颜色生成图片
 *
 *  @param color 颜色
 *
 *  @return 返回对应的图片
 */
+(UIImage *)imageWithColor:(UIColor *)color;
/**
 *  生成带虚线边的图片
 *
 *  @param size        图片的大小
 *  @param color       虚边颜色
 *  @param borderWidth 虚边的宽度
 *
 *  @return 返回对应的图片
 */
+(UIImage*)imageWithSize:(CGSize)size borderColor:(UIColor *)color borderWidth:(CGFloat)borderWidth;

@end