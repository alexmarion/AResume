//
//  WTYUVInputCamera.m
//  DevApplication
//
//  Created by Andreas Schacherbauer on 14/03/16.
//  Copyright © 2016 Wikitude. All rights reserved.
//

#import "WTYUVInputCamera.h"

#import "WTDeviceCamera.h"
#include "YUVFrameInputPlugin.hpp"


@interface WTYUVInputCamera () <AVCaptureVideoDataOutputSampleBufferDelegate, WTDeviceCameraDelegate>

@property (nonatomic, strong) WTDeviceCamera                            *camera;

@property (nonatomic, assign) std::shared_ptr<YUVFrameInputPlugin>      cameraInputPlugin;

@property (nonatomic, assign) std::shared_ptr<unsigned char>            cameraData;

@end

@implementation WTYUVInputCamera

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _camera = [[WTDeviceCamera alloc] initWithDevicePosition:AVCaptureDevicePositionBack preset:AVCaptureSessionPreset640x480 settings:[WTDeviceCamera defaultYUVDeviceCameraSettings] sampleBufferDelegate:self];
        _camera.delegate = self;

        _cameraInputPlugin = std::make_shared<YUVFrameInputPlugin>(_camera);
    }

    return self;
}

- (std::shared_ptr<YUVFrameInputPlugin>&)cameraInputPlugin
{
    return _cameraInputPlugin;
}

#pragma mark - Delegation
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if ( imageBuffer )
    {
        if ( kCVReturnSuccess == CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly) )
        {
            size_t frameDataSize = CVPixelBufferGetDataSize(imageBuffer);
            std::shared_ptr<unsigned char> frameData = std::shared_ptr<unsigned char>(new unsigned char[frameDataSize], std::default_delete<unsigned char[]>());
            std::memcpy(frameData.get(), CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0), frameDataSize);            
            _cameraInputPlugin->notifyNewImageBufferData(frameData);
            CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{

}

#pragma mark WTDeviceCameraDelegate
- (void)deviceCamera:(WTDeviceCamera *)camera didChangeAuthorizationStatus:(AVAuthorizationStatus)authorizationStatus
{
    if ( AVAuthorizationStatusNotDetermined == authorizationStatus || AVAuthorizationStatusDenied == authorizationStatus )
    {
    }
}

@end
