//
//  YJImageMgr+ResoureImage.m
//  UpLoaderImage
//
//  Created by 王亚军 on 16/3/24.
//  Copyright © 2016年 王亚军. All rights reserved.
//

#import "YJImageMgr.h"
#import <objc/runtime.h>

@interface ResourceManager : NSObject

@property(nonatomic,strong)NSCache *resoureCache;

+(instancetype)shareResourceManager;

-(UIImage *)resourceKey:(NSString *)key callBack:(UIImage * (^)(NSString *key))callBack;

@end

@implementation YJImageMgr (ResoureImage)

+(UIImage *)imageName:(NSString *)imageName {
    return [[ResourceManager shareResourceManager] resourceKey:imageName callBack:^UIImage *(NSString *key) {
        return  [YJImageMgr imageFormResource:imageName];
    }];

}

+(UIImage *)imageFormResource:(NSString *)imageName scale:(NSInteger)scale {
    
    NSString *imagePath = [self imagePathForName:imageName];
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    return [UIImage imageWithData:data scale:scale];
    
}

+(UIImage *)imageFormResource:(NSString *)imageName {
    
    BOOL isP = [UIScreen mainScreen].scale < 3;
    if (isP) {
        NSString *tmpPath = [imageName stringByAppendingString:@"@2x.png"];
        BOOL is2Scale = [self isResoureImage:tmpPath];
        if (is2Scale) {
            return [self imageFormResource:tmpPath scale:2];
        }
    }
    imageName = [imageName stringByAppendingString:@"@3x.png"];
    BOOL is3Scale = [self isResoureImage:imageName];
    if (!is3Scale) {
        return nil;
    }
    return [self imageFormResource:imageName scale:3];
    
}

+(NSString *)imagePathForName:(NSString *)imageName {
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName];
    return imagePath;
}

+(BOOL)isResoureImage:(NSString *)imageName {
    NSString *tmpPath = [self imagePathForName:imageName];
    return [[NSFileManager defaultManager] fileExistsAtPath:tmpPath];
}

+(UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)imageWithSize:(CGSize)size borderColor:(UIColor *)color borderWidth:(CGFloat)borderWidth
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [[UIColor clearColor] set];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGFloat lengths[] = { 3, 1 };
    CGContextSetLineDash(context, 0, lengths, 1);
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, size.width, 0.0);
    CGContextAddLineToPoint(context, size.width, size.height);
    CGContextAddLineToPoint(context, 0, size.height);
    CGContextAddLineToPoint(context, 0.0, 0.0);
    CGContextStrokePath(context);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
@implementation ResourceManager

+(instancetype)shareResourceManager {
    static ResourceManager *_share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _share = [[ResourceManager alloc] initSuper];
    });
    return _share;
}
-(instancetype)initSuper {
    self = [super init];
    if (self) {
        self.resoureCache = [[NSCache alloc] init];
        self.resoureCache.countLimit = 20;
    }
    return self;
}
-(UIImage *)resourceKey:(NSString *)key callBack:(UIImage * (^)(NSString *key))callBack{
    UIImage *image = [self.resoureCache objectForKey:key];
    if (!image) {
        image = callBack(key);
        if (image) {
            [self.resoureCache setObject:image forKey:key];
        }
    }
    return image;
}
@end

@interface UIImage (Resoure)

@end

@implementation UIImage (Resoure)

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)  {    // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);    // class_addMethod will fail if original method already exists
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+(void)load {
    swizzleMethod([self class], @selector(imageNamed:), @selector(imageFormResoure:));
}
+(UIImage *)imageFormResoure:(NSString *)imagename {
    UIImage *image = [YJImageMgr imageName:imagename];
    if (image) {
        return image;
    }
    return [UIImage imageFormResoure:imagename];
}
@end


