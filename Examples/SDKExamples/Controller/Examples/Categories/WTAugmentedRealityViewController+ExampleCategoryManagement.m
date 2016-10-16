//
//  WTAugmentedRealityViewController+ExampleCategoryManagement.m
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 25/09/14.
//  Copyright (c) 2014 Wikitude. All rights reserved.
//

#import "WTAugmentedRealityViewController+ExampleCategoryManagement.h"

#import "WTAugmentedRealityExperience.h"

#import "WTAugmentedRealityViewController+ApplicationModelExample.h"
#import "WTAugmentedRealityViewController+PresentingPoiDetails.h"
#import "WTAugmentedRealityViewController+ScreenshotSharing.h"
#import "WTAugmentedRealityViewController+PluginLoading.h"

NSString * const kWTAugmentedRealityViewControllerExtensionKey_ObtainPoiDataFromApplicationModel = @"ObtainPoiDataFromApplicationModel";
NSString * const kWTAugmentedRealityViewControllerExtensionKey_Barcode = @"LoadQRandBarcodePlugin";
NSString * const kWTAugmentedRealityViewControllerExtensionKey_FaceDetection = @"LoadFaceDetectionPlugin";
NSString * const kWTAugmentedRealityViewControllerExtensionKey_CustomCamera = @"LoadCustomCameraPlugin";
NSString * const kWTAugmentedRealityViewControllerExtensionKey_MarkerTracking = @"LoadMarkerTrackingPlugin";

@implementation WTAugmentedRealityViewController (ExampleCategoryManagement)

#pragma mark - Public Methods

- (void)loadExampleSpecificCategoryForAugmentedRealityExperience:(WTAugmentedRealityExperience *)augmentedRealityExperience
{
    if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_ObtainPoiDataFromApplicationModel] )
    {
        [self startLocationUpdatesForPoiInjection];
    }
    else if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_Barcode] )
    {
        [self loadNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    }
    else if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_FaceDetection] )
    {
        [self loadNamedPlugin:kWTPluginIdentifier_FacedetectionPlugin];
    }
    else if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_CustomCamera] )
    {
        [self loadNamedPlugin:kWTPluginIdentifier_CustomCameraPlugin];
    }
    else if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_MarkerTracking] )
    {
        [self loadNamedPlugin:kWTPluginIdentifier_MarkerTrackingPlugin];
    }
}

- (void)startExampleSpecificCategoryForAugmentedRealityExperience:(WTAugmentedRealityExperience *)augmentedRealityExperience
{
    if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_Barcode] )
    {
        [self startNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    }
    else if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_FaceDetection] )
    {
        [self startNamedPlugin:kWTPluginIdentifier_FacedetectionPlugin];
    }
    else if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_CustomCamera] )
    {
        [self startNamedPlugin:kWTPluginIdentifier_CustomCameraPlugin];
    }
    else if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_MarkerTracking] )
    {
        [self startNamedPlugin:kWTPluginIdentifier_MarkerTrackingPlugin];
    }
}

- (void)stopExampleSpecificCategoryForAugmentedRealityExperience:(WTAugmentedRealityExperience *)augmentedRealityExperience
{
    if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_Barcode] )
    {
        [self stopNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    }
    else if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_FaceDetection] )
    {
        [self stopNamedPlugin:kWTPluginIdentifier_FacedetectionPlugin];
    }
    else if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_CustomCamera] )
    {
        [self stopNamedPlugin:kWTPluginIdentifier_CustomCameraPlugin];
    }
    else if ( [augmentedRealityExperience.requiredViewControllerExtension isEqualToString:kWTAugmentedRealityViewControllerExtensionKey_MarkerTracking] )
    {
        [self stopNamedPlugin:kWTPluginIdentifier_MarkerTrackingPlugin];
    }
}

@end
