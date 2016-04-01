//
//  YJImageMgr.m
//  UpLoaderImage
//
//  Created by 王亚军 on 16/3/23.
//  Copyright © 2016年 王亚军. All rights reserved.
//

#import "YJImageMgr.h"

@implementation YJImageMgr
+(instancetype)shareImageMgr {
    static YJImageMgr *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[YJImageMgr alloc] init];
    });
    return share;
}

+(UIImage *)fixOrientation:(UIImage *)image {

        // No-op if the orientation is already correct
        if (image.imageOrientation == UIImageOrientationUp) return image;
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        CGAffineTransform transform = CGAffineTransformIdentity;
        
        switch (image.imageOrientation) {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
                transform = CGAffineTransformRotate(transform, M_PI);
                break;
                
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                transform = CGAffineTransformTranslate(transform, image.size.width, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
                break;
                
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, 0, image.size.height);
                transform = CGAffineTransformRotate(transform, -M_PI_2);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationUpMirrored:
                break;
        }
        
        switch (image.imageOrientation) {
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, image.size.width, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
                
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, image.size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationDown:
            case UIImageOrientationLeft:
            case UIImageOrientationRight:
                break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                                 CGImageGetBitsPerComponent(image.CGImage), 0,
                                                 CGImageGetColorSpace(image.CGImage),
                                                 CGImageGetBitmapInfo(image.CGImage));
        CGContextConcatCTM(ctx, transform);
        switch (image.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                // Grr...
                CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
                break;
                
            default:
                CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
                break;
        }
        
        // And now we just create a new UIImage from the drawing context
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        return img;

}
+(NSData *)fixImage:(UIImage *)image MaxSize:(CGFloat)max {
    double i = 0.5f;
    NSData *imageData;
    do {
        imageData = UIImageJPEGRepresentation(image, i);
        i -= 0.1;
    } while (([imageData length] > max * 1024 * 1024)&& i >= 0.1);
    
    return imageData;
}
@end

@implementation YJImageMgr (upLoaderImage)

-(NSData *)upLoaderDataWithImage:(UIImage *)upImage {
    return [self upLoaderDataWithImage:upImage maxCCSize:CGSizeMake(400, 100) maxNRsize:200];
}
/**
 *  压缩具体的图片
 *
 *  @param upImage 需要压缩的图片
 *  @param ccSize  图片最大尺寸
 *  @param crSize  图片最大内容
 *
 *  @return 压缩后的图片数据
 */
-(NSData *)upLoaderDataWithImage:(UIImage *)upImage maxCCSize:(CGSize)ccSize maxNRsize:(CGFloat)nrSize{
    
    upImage = [YJImageMgr fixOrientation:upImage];
    CGSize imageScaleSize = CGSizeMake(upImage.size.width * upImage.scale, upImage.size.height * upImage.scale);
    UIImage *image = upImage;
    CGSize cutSize;
    if (imageScaleSize.height > ccSize.height || imageScaleSize.width > ccSize.width) {
        cutSize = [self cutImageSize:imageScaleSize maxCCSize:ccSize];
        image = [self imageCutImage:upImage size:cutSize];
    }
    return [self imageData:image maxNRSize:nrSize];
}
/**
 *  图片尺寸裁剪算法 会保证最小压缩的边，不会小于要求裁剪边的一半
 *  如果图片自身的一条边比对应要求的边的一半还小，则直接返回
 *  @param imageSize 图片的尺寸
 *  @param ccSize    限制的尺寸
 *
 *  @return 计算后图片压缩的尺寸
 */
-(CGSize)cutImageSize:(CGSize)imageSize maxCCSize:(CGSize)ccSize {
    
    // 1 图片一条边小于对应边的一半，则直接返回
    if(imageSize.width <= ccSize.width/2 || imageSize.height <= ccSize.height/2) {
        return imageSize;
    }
    // 2 计算图片的放缩比
    CGFloat scaleH = ccSize.height/imageSize.height;
    CGFloat scaleW = ccSize.width/imageSize.width;
    // 3 如果图片的高放缩比小于宽的放缩比
    if (scaleH < scaleW) {
        CGFloat width = ccSize.width/2;
        if (scaleH *imageSize.width < width) {
            return CGSizeMake(width, width/imageSize.width * imageSize.height);
        }
        return CGSizeMake(imageSize.width * scaleH, ccSize.height);
    }else {
        CGFloat height = ccSize.height/2;
        if (scaleW *imageSize.height < height) {
            return CGSizeMake(height/imageSize.height *imageSize.width, height);
        }
        return CGSizeMake(ccSize.width, imageSize.height*scaleW);
    }
}
/**
 *  压缩图片数据
 *
 *  @param image     需要压缩的图片
 *  @param maxNRSize 最大限制
 *
 *  @return 返回压缩后的图片数据 说明，可能会出现压缩后的数据大于最大限制目的，保证图片的压缩质量
 */
-(NSData *)imageData:(UIImage *)image maxNRSize:(CGFloat)maxNRSize {
    return [YJImageMgr fixImage:image MaxSize:.2];
}
/**
 *  缩放图片
 *
 *  @param image 原图
 *  @param size  缩放size
 *
 *  @return 依据size缩放后的图片
 */
-(UIImage *)imageCutImage:(UIImage *)image size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    if(scaleImage == nil) {
        NSLog(@"could not scale image");
        return image;
    }
    UIGraphicsEndImageContext();
    return scaleImage;
}

@end
