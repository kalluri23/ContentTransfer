//
//  CTQRScanner.m
//  contenttransfer
//
//  Created by Sun, Xin on 9/29/17.
//  Copyright © 2017 Verizon Wireless Inc. All rights reserved.
//

#import "CTQRScanner.h"

@interface CTQRScanner() <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;

@property (nonatomic, strong) dispatch_queue_t scannerQueue;

/*! Main view to contain the camera.*/
@property (nonatomic, strong) UIView *captureSectionView;
/*! The red boarder when valid QR code is inside the camera view.*/
@property (nonatomic, strong) UIView *highlightView;
/*! The layer for video capture session. This is sublayer of captureSectionView.*/
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

/*! After camera captured valid code and processing it, this one will change from NO to YES, to ignore future incoming code reading.*/
@property (nonatomic, assign) BOOL stopScanning;
/*! When alert showed, change this from NO to YES, to ignore future incoming code reading. Outside object, calling scannerShouldIgnoreFutherReadForAlert and scannerShouldstartReading to change the property.*/
@property (nonatomic, assign) BOOL moreCodeAlertShowed;
/*! When camera focus on more than two QR codes for more than 15 times, means user intent to do this; Change this value to YES to show the alert for user.*/
@property (nonatomic, assign) BOOL moreThanOneBarCodeErr;

/*! Count for camera focusing to only one barcode, current barcode moving out or camera, blur, or more than one code comming, will reset this count.*/
@property (nonatomic, assign) int onlyOneBarCodeCount;
/*! Count for camera focusing on more than one code. When all codes that beyond one moving out of camera will reset this count.*/
@property (nonatomic, assign) int moreThanOneBarCodeCount;

/*! Save the attached view for scanner.*/
@property (nonatomic, assign) UIView *targetView;
@end

@implementation CTQRScanner
#pragma mark - Static statements
/*! Count limit for camera focusing on the code. The bigger number assiged, more time will be required for user to focus.*/
static int CTOnlyOneBarCodeLimit = 15;
static char *const scannerQueueName = "QRCodeScannerQueue";

#pragma mark - Initializer
+ (instancetype)shared {
    static CTQRScanner *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)enableScannerforTarget:(UIView *)view {
    self.scannerError = nil;
    self.targetView = view;
    // Reset sesstion
    if (_captureSession.isRunning) {
        [self stopScanner];
    }
    
    // Try to enable the scanner for QR code
    self.isScannerEnabled = [self initScanner:view.frame];

}

#pragma mark - Convenients
- (BOOL)initScanner:(CGRect)frame {
    // Clear properties
    self.isScannerEnabled = NO;
    self.captureSession = nil;
    self.videoPreviewLayer = nil;
    self.captureSectionView = nil;
    self.highlightView = nil;
    self.moreCodeAlertShowed = NO;
    
    // Init
    NSError *error = nil;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        self.scannerError = error; // Assign the error to the object error property.
        return NO;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(scannerQueueName, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.captureSectionView = [[UIView alloc] init];
//    self.captureSectionView.backgroundColor = [UIColor redColor];
    
    self.highlightView = [[UIView alloc] init];
    self.highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.highlightView.layer.borderColor = [CTMVMColor mvmPrimaryRedColor].CGColor;
    self.highlightView.layer.borderWidth = 1;
    [self.captureSectionView addSubview:self.highlightView];
    [self.captureSectionView bringSubviewToFront:self.highlightView];
    
    return YES;
}

#pragma mark - Scanner operations
- (void)startScanner {
    // Reset property
    self.stopScanning = NO;
    // Start scan session
    if (self.captureSession) {
        [self.captureSession startRunning];
        self.scannerStarted = YES;
    }
}

- (void)stopScanner {
    // Clear property
    _onlyOneBarCodeCount     = 0;
    _moreThanOneBarCodeCount = 0;
    // Stop scan session
    if (self.captureSession) {
        [self.captureSession stopRunning];
        self.scannerStarted = NO;
    }
}

- (void)attachScanner {
    self.captureSectionView.frame = self.targetView.bounds;
    [self.captureSectionView layoutIfNeeded];
    
    [_videoPreviewLayer setFrame:self.captureSectionView.layer.bounds];
    [self.captureSectionView.layer addSublayer:_videoPreviewLayer];
    
    [self.captureSectionView bringSubviewToFront:self.highlightView];
    
    [self.targetView addSubview:self.captureSectionView];
    [self.targetView bringSubviewToFront:self.captureSectionView];
}

- (void)detachScanner {
    [self.highlightView setFrame:CGRectZero];
    [self.highlightView layoutIfNeeded];
    [self.captureSectionView removeFromSuperview];
}

- (void)scannerShouldIgnoreFutherReadForAlert {
    self.moreCodeAlertShowed = YES;
}

- (void)scannerShouldstartReading {
    self.moreCodeAlertShowed = NO;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (_stopScanning) { // Ignore all the coming captures after scanning stopped.
        NSLog(@"Should ignore this request");
        return;
    }
    
    CGRect highlightViewRect = CGRectZero;
    int cornerDetected = 0;
    AVMetadataMachineReadableCodeObject *barCodeObject = nil;
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        NSLog(@"Found QR code: %ld", (unsigned long)metadataObjects.count);
        if ([metadataObjects count] > 1) { // More than 1 code detected at the same time.
            _onlyOneBarCodeCount = 0;
            
            if (!_moreCodeAlertShowed && ++_moreThanOneBarCodeCount >= CTOnlyOneBarCodeLimit) {
                self.moreThanOneBarCodeErr = YES;
                self.stopScanning = YES;
            }
            
        } else { // Single code detected.
            _moreThanOneBarCodeCount = 0;
            barCodeObject = (AVMetadataMachineReadableCodeObject *)[self.videoPreviewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)[metadataObjects objectAtIndex:0]];
            if ([[barCodeObject type] isEqualToString:AVMetadataObjectTypeQRCode]) {
                // Check corners
                NSArray *corners = barCodeObject.corners;
                for (NSDictionary *point in corners) {
                    if ([point floatForKey:@"X"] < 0 || [point floatForKey:@"X"] > _videoPreviewLayer.frame.size.width || [point floatForKey:@"Y"] < 0 || [point floatForKey:@"Y"] > _videoPreviewLayer.frame.size.height) {
                        NSLog(@"outside the camera");
                        break;
                    }
                    
                    cornerDetected++;
                }
                
                if (cornerDetected == 4) { // When 4 corners all detected, means user put full QR code inside the camera
                    highlightViewRect = barCodeObject.bounds;
                    
                    if (!_moreCodeAlertShowed && ++_onlyOneBarCodeCount >= CTOnlyOneBarCodeLimit) {
                        self.moreThanOneBarCodeErr = NO;
                        self.stopScanning = YES;
                    }
                } else {
                    _onlyOneBarCodeCount = 0;
                }
            } else {
                _onlyOneBarCodeCount = 0;
            }
        }
    } else {
        _onlyOneBarCodeCount = 0;
        _moreThanOneBarCodeCount = 0;
    }
    // Process the code reading
    dispatch_async(dispatch_get_main_queue(), ^{
        self.highlightView.frame = highlightViewRect;
        
        if (_stopScanning) { // Only when reading the valid codes will change this to YES.
            [self stopScanner];
            [self detachScanner];
            if (self.targetView) {
                [self.targetView layoutSubviews];
            }
            
            NSAssert(self.delegate != nil, @"Delegate is needed."); // Expect crash if there is no delegate assigned.
            if (barCodeObject != nil && barCodeObject.stringValue != nil) {
                [self.delegate QRScanner:self didSuccessfullyScannedQRCode:barCodeObject.stringValue];
            } else {
                // invalid code text
                _moreCodeAlertShowed = YES;
                NSString *errMsg = _moreThanOneBarCodeErr ? CTLocalizedString(CT_ERROR_READING_CODE_ALERT_CONTEXT, nil) : CTLocalizedString(CT_ERROR_READING_CODE_ALERT_CONTEXT, nil);
                [self.delegate QRScanner:self didFailedScannedQRCode:errMsg handler:^{
                    self.moreCodeAlertShowed = NO;
                }];
                
                [self attachScanner];
                [self startScanner];
            }
        }
    });
}

@end
