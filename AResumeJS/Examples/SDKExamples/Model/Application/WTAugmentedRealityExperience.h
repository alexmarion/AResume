//
//  WTAugmentedRealityExperience.h
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 23/09/14.
//  Copyright (c) 2014 Wikitude. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WikitudeSDK/WikitudeSDK.h>


extern NSString * const kWTAugmentedRealityExperienceStartupParameterKey_CaptureDevicePosition;
extern NSString * const kWTAugmentedRealityExperienceStartupParameterKey_CaptureDevicePosition_Back;



/**
 * WTAugmentedRealityExperience class
 *
 * This class represents a Wikitude SDK example in this application.
 * A example has a title, group title, URL and required augmented reality features which specifies the requirements the ARchitect World has in regards of functionality.
 *
 * Also custom URLs are represented as an object of this class.
 */
@interface WTAugmentedRealityExperience : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString                        *title;
@property (nonatomic, strong, readonly) NSString                        *groupTitle;
@property (nonatomic, strong, readonly) NSURL                           *URL;
@property (nonatomic, assign, readonly) WTFeatures                      requiredFeatures;
@property (nonatomic, strong, readonly) NSDictionary                    *startupParameters;
@property (nonatomic, strong, readonly) NSString                        *requiredViewControllerExtension; /* nil by default */


+ (WTAugmentedRealityExperience *)experienceWithTitle:(NSString *)title groupTitle:(NSString *)groupTitle URL:(NSURL *)URL requiredFeatures:(WTFeatures)features startupParameters:(NSDictionary *)startupParameters requiredViewControllerExtension:(NSString *)requiredViewControllerExtension;

@end
