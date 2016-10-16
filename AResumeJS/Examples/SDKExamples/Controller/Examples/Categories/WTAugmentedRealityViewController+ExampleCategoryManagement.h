//
//  WTAugmentedRealityViewController+ExampleCategoryManagement.h
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 25/09/14.
//  Copyright (c) 2014 Wikitude. All rights reserved.
//

#import "WTAugmentedRealityViewController.h"

extern NSString * const kWTAugmentedRealityViewControllerExtensionKey_ObtainPoiDataFromApplicationModel;
extern NSString * const kWTAugmentedRealityViewControllerExtensionKey_Barcode;
extern NSString * const kWTAugmentedRealityViewControllerExtensionKey_FaceDetection;


@class WTAugmentedRealityExperience;

/**
 * WTAugmentedRealityViewController (ExampleCategoryManagement)
 *
 * This category executes example specific iOS code.
 */
@interface WTAugmentedRealityViewController (ExampleCategoryManagement)

- (void)loadExampleSpecificCategoryForAugmentedRealityExperience:(WTAugmentedRealityExperience *)augmentedRealityExperience;
- (void)startExampleSpecificCategoryForAugmentedRealityExperience:(WTAugmentedRealityExperience *)augmentedRealityExperience;
- (void)stopExampleSpecificCategoryForAugmentedRealityExperience:(WTAugmentedRealityExperience *)augmentedRealityExperience;
@end
