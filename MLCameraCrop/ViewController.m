//
//  ViewController.m
//  MLCameraCrop
//
//  Created by molon on 2017/6/6.
//  Copyright © 2017年 molon. All rights reserved.
//

#import "ViewController.h"
#import "MLCameraCropViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickButton:(id)sender {
    MLCameraCropViewController *vc = [MLCameraCropViewController new];
    vc.cropFrame = CGRectMake(87.5, 200, 200, 200);
    vc.tips = @"取景框描述，不能字太长，没做自适应";
    [vc setDidCaptureImageBlock:^(UIImage *image,MLCameraCropViewController *vc) {
        _imageView.image = image;
        [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:vc] animated:YES completion:nil];
}


@end
