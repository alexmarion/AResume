//
//  WTAugmentedRealityViewController+PluginLoading.m
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 27/07/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#import "WTAugmentedRealityViewController+PluginLoading.h"

#include <memory>
#import <objc/runtime.h>

#import <WikitudeSDK/WTArchitectView+Plugins.hpp>
#import "BarcodePlugin.h"
#import "WTFaceDetectionPluginWrapper.h"
#import "YUVFrameInputPlugin.hpp"
#import "WTYUVInputCamera.h"
#import "MarkerTrackingPlugin.h"

static const char *kWTAugmentedRealityViewController_AssociatedFaceDetectionPluginWrapperKey = "kWTARVCAFDPWK";
static const char *kWTAugmentedRealityViewController_AssociatedYUVInputCameraWrapperKey = "kWTARVCAYUVICWK";

NSString * const kWTPluginIdentifier_BarcodePlugin = @"com.wikitude.plugin.barcode";
NSString * const kWTPluginIdentifier_FacedetectionPlugin = @"com.wikitude.plugin.face_detection";
NSString * const kWTPluginIdentifier_CustomCameraPlugin = @"com.wikitude.plugin.customcamera";
NSString * const kWTPluginIdentifier_MarkerTrackingPlugin = @"com.wikitude.plugin.markertracking";


@implementation WTAugmentedRealityViewController (PluginLoading)

- (void)loadNamedPlugin:(NSString *)pluginName
{
    if ( [pluginName isEqualToString:kWTPluginIdentifier_BarcodePlugin] )
    {
    }
    else if ( [pluginName isEqualToString:kWTPluginIdentifier_FacedetectionPlugin] )
    {        
        WTFaceDetectionPluginWrapper *faceDetectionPluginWrapper = [[WTFaceDetectionPluginWrapper alloc] init];
        objc_setAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedFaceDetectionPluginWrapperKey, faceDetectionPluginWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else if ( [pluginName isEqualToString:kWTPluginIdentifier_CustomCameraPlugin] )
    {
        WTYUVInputCamera *yuvInputCamera = [[WTYUVInputCamera alloc] init];
        objc_setAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedYUVInputCameraWrapperKey, yuvInputCamera, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else if ( [pluginName isEqualToString:kWTPluginIdentifier_MarkerTrackingPlugin] )
    {
    }
}

- (void)startNamedPlugin:(NSString *)pluginName
{
    if ( [pluginName isEqualToString:kWTPluginIdentifier_BarcodePlugin] )
    {
        [self.architectView registerPlugin:std::make_shared<BarcodePlugin>([kWTPluginIdentifier_BarcodePlugin cStringUsingEncoding:NSUTF8StringEncoding], 640, 480)];
    }
    else if ( [pluginName isEqualToString:kWTPluginIdentifier_FacedetectionPlugin] )
    {
        WTFaceDetectionPluginWrapper *faceDetectionPluginWrapper = objc_getAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedFaceDetectionPluginWrapperKey);
        if ( faceDetectionPluginWrapper )
        {
            [faceDetectionPluginWrapper start];
//            [faceDetectionPluginWrapper updateOrientation];
#ifndef SIMULATOR_BUILD
            [self.architectView registerPlugin:faceDetectionPluginWrapper.faceDetectionPlugin];
#endif
        }
    }
    else if ( [pluginName isEqualToString:kWTPluginIdentifier_CustomCameraPlugin] )
    {
        WTYUVInputCamera *yuvInputCamera = objc_getAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedYUVInputCameraWrapperKey);
        if (yuvInputCamera)
        {
            [self.architectView registerPlugin:[yuvInputCamera cameraInputPlugin]];
        }
    }
    else if ( [pluginName isEqualToString:kWTPluginIdentifier_MarkerTrackingPlugin] )
    {
#ifndef SIMULATOR_BUILD
        [self.architectView registerPlugin:std::make_shared<MarkerTrackingPlugin>()];
#endif
    }
}

- (void)stopNamedPlugin:(NSString *)pluginName
{
    if ( [pluginName isEqualToString:kWTPluginIdentifier_BarcodePlugin] )
    {
        [self.architectView removeNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    }
    else if ( [pluginName isEqualToString:kWTPluginIdentifier_FacedetectionPlugin] )
    {
#ifndef SIMULATOR_BUILD
        WTFaceDetectionPluginWrapper *faceDetectionPluginWrapper = objc_getAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedFaceDetectionPluginWrapperKey);
        [faceDetectionPluginWrapper stop];
        [self.architectView removePlugin:faceDetectionPluginWrapper.faceDetectionPlugin];
#endif
    }
    else if ([pluginName isEqualToString:kWTPluginIdentifier_CustomCameraPlugin] )
    {
        WTYUVInputCamera *yuvInputCamera = objc_getAssociatedObject(self, kWTAugmentedRealityViewController_AssociatedYUVInputCameraWrapperKey);
        if (yuvInputCamera)
        {
            [self.architectView removePlugin:[yuvInputCamera cameraInputPlugin]];
        }
    }
    else if ( [pluginName isEqualToString:kWTPluginIdentifier_MarkerTrackingPlugin] )
    {
#ifndef SIMULATOR_BUILD
        [self.architectView removeNamedPlugin:kWTPluginIdentifier_MarkerTrackingPlugin];
#endif
    }
}

@end
