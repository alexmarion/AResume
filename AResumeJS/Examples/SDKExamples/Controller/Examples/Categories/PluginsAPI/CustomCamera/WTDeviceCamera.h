//
//  WTDeviceCamera.h
//  DevApplication
//
//  Created by Andreas Schacherbauer on 10/03/16.
//  Copyright © 2016 Wikitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>



@class WTDeviceCamera;
@protocol WTDeviceCameraDelegate <NSObject>

- (void)deviceCamera:(WTDeviceCamera *)camera didChangeAuthorizationStatus:(AVAuthorizationStatus)authorizationStatus;

@end

@interface WTDeviceCamera : NSObject

@property (nonatomic, weak) id<WTDeviceCameraDelegate>                  delegate;

@property (nonatomic, readonly) CGFloat                                 fieldOfView;
@property (nonatomic, readonly) CMVideoDimensions                       videoDimensions;

+ (NSDictionary *)defaultYUVDeviceCameraSettings;
+ (NSDictionary *)defaultRGBDeviceCameraSettings;

- (instancetype)initWithDevicePosition:(AVCaptureDevicePosition)captureDevicePosition preset:(NSString *)captureSessionPreset settings:(NSDictionary *)captureSettings sampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate;

- (BOOL)initialize;

- (BOOL)startRunning;
- (void)stopRunning;

- (void)shutdown;

@end
