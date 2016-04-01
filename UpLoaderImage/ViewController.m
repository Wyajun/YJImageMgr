//
//  ViewController.m
//  UpLoaderImage
//
//  Created by 王亚军 on 16/3/23.
//  Copyright © 2016年 王亚军. All rights reserved.
//

#import "ViewController.h"
#import "JDImagePickerViewController.h"
#import "YJImageMgr.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *bnt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.view addSubview:bnt];
    bnt.center = self.view.center;
    bnt.backgroundColor = [UIColor redColor];
    [bnt addTarget:self action:@selector(presentVc) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)presentVc {
    [[YJImageMgr shareImageMgr] upLoaderDataWithImage:[UIImage imageNamed:@"ceshi1"]];
//   [[JDImagePickerViewController shareImagePickerViewController] presentViewController:self imagePickType:imageFromCamera completion:^(UIImage *image) {
//      NSData *data = [[YJImageMgr shareImageMgr] upLoaderDataWithImage:image];
//       NSLog(@"length ===   %@",@(data.length));
//   } edit:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
