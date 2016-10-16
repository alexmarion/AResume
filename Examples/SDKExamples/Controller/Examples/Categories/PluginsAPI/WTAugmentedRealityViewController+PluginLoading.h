//
//  WTAugmentedRealityViewController+PluginLoading.h
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 27/07/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#import "WTAugmentedRealityViewController.h"

extern NSString * const kWTPluginIdentifier_BarcodePlugin;
extern NSString * const kWTPluginIdentifier_FacedetectionPlugin;
extern NSString * const kWTPluginIdentifier_CustomCameraPlugin;
extern NSString * const kWTPluginIdentifier_MarkerTrackingPlugin;

@interface WTAugmentedRealityViewController (PluginLoading)

- (void)loadNamedPlugin:(NSString *)pluginName;

- (void)startNamedPlugin:(NSString *)pluginName;
- (void)stopNamedPlugin:(NSString *)pluginName;

@end
