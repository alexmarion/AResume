//
//  WTDeviceCamera.m
//  DevApplication
//
//  Created by Andreas Schacherbauer on 10/03/16.
//  Copyright © 2016 Wikitude. All rights reserved.
//

#import "WTDeviceCamera.h"

#import <CoreVideo/CVPixelBuffer.h>

@interface WTDeviceCamera ()

@property (nonatomic, weak) id<AVCaptureVideoDataOutputSampleBufferDelegate>    sampleBufferDelegate;

@property (nonatomic, assign) AVCaptureDevicePosition           captureDevicePosition;

@property (nonatomic, strong) NSString                          *captureSessionPreset;
@property (nonatomic, strong) NSDictionary                      *captureSettings;

@property (nonatomic, strong) AVCaptureDevice                   *captureDevice;
@property (nonatomic, strong) AVCaptureSession                  *captureSession;

@property (nonatomic, assign) CGFloat                           captureDeviceFieldOfView;
@property (nonatomic, assign) CMVideoDimensions                 captureDeviceVideoDimensions;

@property (nonatomic, strong) dispatch_queue_t                  dataOutputQueue;

@end

@implementation WTDeviceCamera

+ (NSDictionary *)defaultYUVDeviceCameraSettings
{
    return @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
}

+ (NSDictionary *)defaultRGBDeviceCameraSettings
{
    return @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_24RGB)};
}

- (instancetype)initWithDevicePosition:(AVCaptureDevicePosition)captureDevicePosition preset:(NSString *)captureSessionPreset settings:(NSDictionary *)captureSettings sampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate
{
    self = [super init];
    if (self) {

        _captureDevicePosition = captureDevicePosition;
        _captureSessionPreset = [captureSessionPreset copy];
        _captureSettings = [captureSettings copy];
        _sampleBufferDelegate = sampleBufferDelegate;

        _captureSession = [[AVCaptureSession alloc] init];

        dispatch_queue_attr_t queue_attr = DISPATCH_QUEUE_SERIAL;
        if ( NULL != &dispatch_queue_attr_make_with_qos_class ) {
            queue_attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INTERACTIVE, 0);
        }
        _dataOutputQueue = dispatch_queue_create("com.wikitude.capture_data_output", queue_attr);
    }

    return self;
}

#pragma mark - Public Methods

- (CGFloat)fieldOfView
{
    return _captureDeviceFieldOfView;
}

- (CMVideoDimensions)videoDimensions
{
    return _captureDeviceVideoDimensions;
}

- (BOOL)initialize
{
    BOOL initialized = NO;

    AVAuthorizationStatus cameraAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ( AVAuthorizationStatusAuthorized == cameraAuthorizationStatus ) {
        initialized = [self connectCaptureSession];
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if ( !granted )
            {
                if ( self.delegate && [self.delegate respondsToSelector:@selector(deviceCamera:didChangeAuthorizationStatus:)] ) {
                    [self.delegate deviceCamera:self didChangeAuthorizationStatus:[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]];
                }
            }
            else
            {
                [self connectCaptureSession];
            }
        }];
        initialized = NO;
    }

    return initialized;
}

- (BOOL)startRunning
{
    return [self startCaptureSession];
}

- (void)stopRunning
{
    [self stopCaptureSession];
}

- (void)shutdown
{
    [self destroyCaptureDevice];
    [self termiateCaptureSession];
}


#pragma mark - Private Methods

- (BOOL)connectCaptureSession
{
    self.captureDevice = [self prepareCaptureDevice];
    if (!self.captureDevice) {
        return NO;
    }
    self.captureSession = [self prepareCaptureSessionWithCaptureDevice:self.captureDevice];
    if (!self.captureSession) {
        return NO;
    }

    return YES;
}

- (AVCaptureSession *)prepareCaptureSessionWithCaptureDevice:(AVCaptureDevice *)captureDevice
{
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    [captureSession beginConfiguration];

    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:_captureSettings];

    [dataOutput setSampleBufferDelegate:_sampleBufferDelegate queue:_dataOutputQueue];

    if ( [captureSession canAddOutput:dataOutput] ) {
        [captureSession addOutput:dataOutput];
    } else {
        NSLog(@"Unable to add data output %@ to capture session %@.", dataOutput, self.captureSession);
    }


    for (AVCaptureInput *captureInput in [captureSession inputs] )
    {
        [captureSession removeInput:captureInput];
    }


    if ( ![captureSession canSetSessionPreset:_captureSessionPreset] )
    {
        _captureSessionPreset = AVCaptureSessionPreset640x480;
    }
    [captureSession setSessionPreset:_captureSessionPreset];


    NSError *deviceInputError = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&deviceInputError];
    if ( !deviceInput ) {
        NSLog(@"Unable to create capture device input from capture device %@. Reason: %@", captureDevice, [deviceInputError localizedDescription]);
        [_captureSession commitConfiguration];
        return nil;
    }

    if ( ![captureSession canAddInput:deviceInput] ) {
        NSLog(@"Unable to add input %@ to capture session %@", deviceInput, captureSession);
        [_captureSession commitConfiguration];
        return nil;
    }
    [captureSession addInput:deviceInput];
    

    CMFormatDescriptionRef formatDescription = [[captureDevice activeFormat] formatDescription];
    _captureDeviceVideoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);

    [captureSession commitConfiguration];

    return captureSession;
}

- (AVCaptureDevice *)prepareCaptureDevice
{
    AVCaptureDevice *captureDevice = nil;

    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *videoCaptureDevcie in videoDevices )
    {
        if ( videoCaptureDevcie.position == _captureDevicePosition )
        {
            if ( [videoCaptureDevcie supportsAVCaptureSessionPreset:_captureSessionPreset] )
            {
                captureDevice = videoCaptureDevcie;
                _captureDeviceFieldOfView = captureDevice.activeFormat.videoFieldOfView;
            }
            else
            {
                NSLog(@"Capture device %@ does not support session preset %@. Please choose another session preset.", captureDevice, _captureSessionPreset);                
            }
        }
    }

    return captureDevice;
}

- (BOOL)startCaptureSession
{
    if ( ![self.captureSession isRunning] )
    {
        [self.captureSession startRunning];
    }
    
    return [self.captureSession isRunning];
}

- (void)stopCaptureSession
{
    if ( [self.captureSession isRunning] )
    {
        for (AVCaptureInput *input in [self.captureSession inputs])
        {
            [self.captureSession removeInput:input];
        }
        
        for (AVCaptureOutput *output in [self.captureSession outputs])
        {
            [self.captureSession removeOutput:output];
        }
        
        [self.captureSession stopRunning];
    }
}

- (void)destroyCaptureDevice
{
    self.captureDevice = nil;
}

- (void)termiateCaptureSession
{
    [self stopCaptureSession];
    
    self.captureSession = nil;
}

@end
