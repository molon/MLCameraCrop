//
//  MLCameraCropViewController.h
//  MLCameraCrop
//
//  Created by molon on 2017/6/6.
//  Copyright © 2017年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLCameraCropViewController : UIViewController

@property (nonatomic, assign) CGRect cropFrame;
@property (nonatomic, copy) NSString *tips;

@property (nonatomic, copy) void(^didCaptureImageBlock)(UIImage *image,MLCameraCropViewController *vc);

@end
