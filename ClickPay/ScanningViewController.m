//
//  ScanningViewController.m
//  ClickPay
//
//  Created by Thomas Lin on 3/24/14.
//  Copyright (c) 2014 AppCanvas. All rights reserved.
//

#import <AVFoundation/AVCaptureSession.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import "ScanningViewController.h"
#import "MyBillViewController.h"

@interface ScanningViewController () {
    CALayer *__videoPreviewLayer;
}

@property (nonatomic, weak) UIView *scanView;
@property (nonatomic, strong) UIBarButtonItem *torchButton;
@property (nonatomic) BOOL isScanning;
@property (nonatomic) BOOL isTorchOn;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *scanPreviewLayer;

@end

@implementation ScanningViewController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _captureSession = nil;
    _isTorchOn = NO;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissScanViewController)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.title = @"Add new table";
    self.navigationItem.titleView.tintColor = [UIColor whiteColor];
    
    self.torchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"torch-on"] style:UIBarButtonItemStylePlain target:self action:@selector(torchSwitch:)];
    self.navigationItem.rightBarButtonItem = self.torchButton;
    
    
    [self startCaptureSession];
    
    // We have the preview view in a UIView (rather than just adding the layer to the root view)
    // so that we can easily remove all views by calling removeFromSuperview: on all subviews.
    UIView *previewView = [[UIView alloc] initWithFrame:self.view.frame];
    [self startScanningInView:previewView];
    [self.view addSubview:previewView];
    
    UIFont *fontHelveticaNeue = [UIFont fontWithName:@"HelveticaNeueLTStd-Bd" size:20];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(self.view.center.x - 125, self.view.center.y - 130, 250, 50)];
    [textView setText:@"Aligh your scanner with the code on your table"];
    [textView setTextColor:[UIColor whiteColor]];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setFont:fontHelveticaNeue];
    [self.view addSubview:textView];
    
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay"]];
    [overlayImageView setFrame:CGRectMake(self.view.center.x - 100, self.view.center.y - 70, 200, 200)];
    [self.view addSubview:overlayImageView];
    
}

- (void)torchSwitch:(id)sender {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (device.hasFlash && device.hasTorch) {
        [device lockForConfiguration:nil];
        if (!self.isTorchOn) {
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
            [self.torchButton setImage:[UIImage imageNamed:@"torch-off"]];
            self.isTorchOn = YES;
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
            [self.torchButton setImage:[UIImage imageNamed:@"torch-on"]];
            self.isTorchOn = NO;
        }
        [device unlockForConfiguration];
    }
}

- (void)startCaptureSession
{
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetiFrame960x540;
    
    AVCaptureDevice *device;
    for (AVCaptureDevice *candidateDevice in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([candidateDevice position] == AVCaptureDevicePositionBack) {
            device = candidateDevice;
            break;
        }
    }
    if (device == nil) {
        NSLog(@"Unable to find camera");
        exit(1);
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"Couldn't create video capture device");
        NSLog(@"%@", error);
        exit(1);
    }
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Kick it all off.
    [self.captureSession startRunning];
}

- (CALayer *)startScanningInView:(UIView *)view {
    
    _scanPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    _scanPreviewLayer.frame = self.view.frame;

    [view.layer addSublayer:_scanPreviewLayer];
    [view setNeedsDisplay];
    
    return _scanPreviewLayer;
}

- (void)stopScanerWithScanningValue:(NSString *)value {
    [_captureSession stopRunning];
    _captureSession = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MyBillViewController *myBill = (MyBillViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MyBillView"];
    myBill.navigationItem.title = @"My Bill";
    [self.navigationController pushViewController:myBill animated:YES];
}

#pragma mark - AVCapertureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSLog(@"%@", [metadataObject stringValue]);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            SystemSoundID soundID;
            NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"alert_bamboo" ofType:@"aac"];
            AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)[NSURL fileURLWithPath:soundFile], &soundID);
            AudioServicesPlaySystemSound(soundID);
            [self performSelectorOnMainThread:@selector(stopScanerWithScanningValue:) withObject:[metadataObject stringValue] waitUntilDone:YES];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dismissScanViewController {
    [_captureSession stopRunning];
    _captureSession = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
