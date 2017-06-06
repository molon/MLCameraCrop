//
//  MLCameraCropViewController.m
//  MLCameraCrop
//
//  Created by molon on 2017/6/6.
//  Copyright © 2017年 molon. All rights reserved.
//

#import "MLCameraCropViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MLCameraCropViewController ()

@end

@implementation MLCameraCropViewController {
    AVCaptureSession *_session;
    AVCaptureVideoPreviewLayer *_previewLayer;
    AVCaptureStillImageOutput *_output;
    
    CAShapeLayer *_dimmingLayer;
    
    UILabel *_tipsLabel;
    UIButton *_torchButton;
    UIButton *_takeButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"取景";
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    shapeLayer.fillColor = [UIColor colorWithWhite:0.000 alpha:0.650].CGColor;
    shapeLayer.lineWidth = 1.0f;
    shapeLayer.strokeColor = [UIColor colorWithWhite:0.501 alpha:0.800].CGColor;
    [self.view.layer addSublayer:shapeLayer];
    _dimmingLayer = shapeLayer;
    
    _tipsLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textColor = [UIColor whiteColor];
        [self.view addSubview:label];
        label;
    });
    
    _torchButton = ({
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        [b setTitle:@"打开照明灯" forState:UIControlStateNormal];
        [b setTitle:@"关闭照明灯" forState:UIControlStateSelected];
        [b setTitleColor:[UIColor colorWithRed:0.277 green:0.458 blue:0.999 alpha:1.000] forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [b addTarget:self action:@selector(clickTorchButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
        b;
    });
    
    _takeButton = ({
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        [b setTitle:@"拍照" forState:UIControlStateNormal];
        [b setTitleColor:[UIColor colorWithRed:0.277 green:0.458 blue:0.999 alpha:1.000] forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [b addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
        b;
    });
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch]||![device isTorchAvailable]) {
        _torchButton.hidden = YES;
    }else{
        _torchButton.selected = device.torchMode == AVCaptureTorchModeOn;
    }
    
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error||!input) {
        [[[UIAlertView alloc]initWithTitle:@"" message:@"相机打开失败" delegate:nil cancelButtonTitle:@"好的，知道了" otherButtonTitles:nil]show];
        return;
    }
    AVCaptureStillImageOutput *output = [[AVCaptureStillImageOutput alloc] init];
    
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    if ([_session canAddOutput:output]) {
        [_session addOutput:output];
    }
    
    //输出设置AVVideoCodecJPEG 输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [output setOutputSettings:outputSettings];
    _output = output;
    
    //预览图层
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.bounds;
    
    //插入到layer层级最底部
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_session) {
        [_session startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_session) {
        [_session stopRunning];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    [_session stopRunning];
    
    [_previewLayer removeFromSuperlayer];
}

#pragma mark - event
- (void)clickTorchButton {
    _torchButton.selected = !_torchButton.selected;
    [self turnOnLight:_torchButton.selected];
}

#pragma mark - layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    _previewLayer.frame = self.view.bounds;
    
    CGRect centerFrame = _cropFrame;
    
    _dimmingLayer.frame = CGRectInset(self.view.bounds, -1, -1);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:_dimmingLayer.frame];
    [path appendPath:[UIBezierPath bezierPathWithRect:centerFrame]];
    _dimmingLayer.path = path.CGPath;
    
    CGFloat labelWidth = self.view.frame.size.width-10.0f*2;
    _tipsLabel.frame = CGRectMake(10, centerFrame.origin.y+centerFrame.size.height+10.0f, labelWidth, 15.0f);
    
#define kButtonWidth 100.0f
    _torchButton.frame = CGRectMake((self.view.frame.size.width-kButtonWidth)/2.0f, _tipsLabel.frame.origin.y+_tipsLabel.frame.size.height+5.0f, kButtonWidth, 40.0f);
    
    _takeButton.frame = CGRectMake((self.view.frame.size.width-kButtonWidth)/2.0f, _torchButton.frame.origin.y+_torchButton.frame.size.height+5.0f, kButtonWidth, 40.0f);
}

#pragma mark - helper
- (void)turnOnLight:(BOOL)on {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]&&[device isTorchAvailable]) {
        [device lockForConfiguration:nil];
        
        if (on) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode: AVCaptureTorchModeOff];
        }
        
        [device unlockForConfiguration];
    }
}

- (void)takePhoto {
    AVCaptureConnection *stillImageConnection = [_output connectionWithMediaType:AVMediaTypeVideo];
    [stillImageConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [stillImageConnection setVideoScaleAndCropFactor:1];
    
    __weak typeof(self)wSelf = self;
    [_output captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        __strong typeof(self)sSelf = wSelf;
        if (sSelf.didCaptureImageBlock) {
            NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *takenImage = [UIImage imageWithData:jpegData];
            
            CGRect outputRect = [_previewLayer metadataOutputRectOfInterestForRect:_cropFrame];
            CGImageRef takenCGImage = takenImage.CGImage;
            size_t width = CGImageGetWidth(takenCGImage);
            size_t height = CGImageGetHeight(takenCGImage);
            CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height);
            
            CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect);
            takenImage = [UIImage imageWithCGImage:cropCGImage scale:1 orientation:takenImage.imageOrientation];
            CGImageRelease(cropCGImage);
            
            sSelf.didCaptureImageBlock(takenImage,sSelf);
        }
    }];
}

#pragma mark - setter
- (void)setTips:(NSString *)tips {
    _tips = tips;
    
    _tipsLabel.text = tips;
    
    [self.view setNeedsLayout];
}

- (void)setCropFrame:(CGRect)cropFrame {
    _cropFrame = cropFrame;
    
    [self.view setNeedsLayout];
}

@end
