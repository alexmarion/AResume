//
//  WTAugmentedRealityExperience.m
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 23/09/14.
//  Copyright (c) 2014 Wikitude. All rights reserved.
//

#import "WTAugmentedRealityExperience.h"



NSString * const kWTAugmentedRealityExperienceStartupParameterKey_CaptureDevicePosition = @"camera_position";
NSString * const kWTAugmentedRealityExperienceStartupParameterKey_CaptureDevicePosition_Back = @"back";

static NSString * kWTAugmentedRealityExperienceArchiveKey_Title = @"TitleKey";
static NSString * kWTAugmentedRealityExperienceArchiveKey_Group = @"GroupKey";
static NSString * kWTAugmentedRealityExperienceArchiveKey_URL = @"URLKey";
static NSString * kWTAugmentedRealityExperienceArchiveKey_RequiredFeatures = @"FeaturesKey";
static NSString * kWTAugmentedRealityExperienceArchiveKey_StartupParameters = @"StartupParametersKey";
static NSString * kWTAugmentedRealityExperienceArchiveKey_ViewControllerExtension = @"ViewControllerExtensionKey";


@interface WTAugmentedRealityExperience ()

@property (nonatomic, strong) NSString                      *internalTitle;
@property (nonatomic, strong) NSString                      *internalGroupTitle;
@property (nonatomic, strong) NSURL                         *internalURL;
@property (nonatomic, assign) WTFeatures                    internalRequiredFeatures;
@property (nonatomic, strong) NSDictionary                  *internalStartupParameters;
@property (nonatomic, strong) NSString                      *internalRequiredViewControllerExtension;

@end

@implementation WTAugmentedRealityExperience

+ (WTAugmentedRealityExperience *)experienceWithTitle:(NSString *)title groupTitle:(NSString *)groupTitle URL:(NSURL *)URL requiredFeatures:(WTFeatures)features startupParameters:(NSDictionary *)startupParameters requiredViewControllerExtension:(NSString *)requiredViewControllerExtension
{
    WTAugmentedRealityExperience *experience = nil;
    
    if ( [URL isFileURL] )
    {
        if ( [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithCString:[URL fileSystemRepresentation] encoding:[NSString defaultCStringEncoding]]] )
        {
            experience = [[WTAugmentedRealityExperience alloc] initWithTitle:title groupTitle:groupTitle URL:URL requiredFeatures:features startupParameters:startupParameters requiredViewControllerExtension:requiredViewControllerExtension];
        }
    }
    else
    {
        if ( [URL host] )
        {
            experience = [[WTAugmentedRealityExperience alloc] initWithTitle:title groupTitle:groupTitle URL:URL requiredFeatures:features startupParameters:startupParameters requiredViewControllerExtension:requiredViewControllerExtension];
        }
    }
    
    return experience;
}

- (instancetype)initWithTitle:(NSString *)title groupTitle:(NSString *)groutTitle URL:(NSURL *)URL requiredFeatures:(WTFeatures)features startupParameters:(NSDictionary *)startupParameters requiredViewControllerExtension:(NSString *)requiredViewControllerExtension
{
    self = [super init];
    if (self)
    {
        _internalTitle = title;
        _internalGroupTitle = groutTitle;
        _internalURL = URL;
        _internalRequiredFeatures = features;
        _internalStartupParameters = startupParameters;
        _internalRequiredViewControllerExtension = requiredViewControllerExtension;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        _internalTitle = [decoder decodeObjectForKey:kWTAugmentedRealityExperienceArchiveKey_Title];
        _internalGroupTitle = [decoder decodeObjectForKey:kWTAugmentedRealityExperienceArchiveKey_Group];
        _internalURL = [decoder decodeObjectForKey:kWTAugmentedRealityExperienceArchiveKey_URL];
        _internalRequiredFeatures = [[decoder decodeObjectForKey:kWTAugmentedRealityExperienceArchiveKey_RequiredFeatures] integerValue];
        _internalStartupParameters = [decoder decodeObjectForKey:kWTAugmentedRealityExperienceArchiveKey_StartupParameters];
        _internalRequiredViewControllerExtension = [decoder decodeObjectForKey:kWTAugmentedRealityExperienceArchiveKey_ViewControllerExtension];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_internalTitle forKey:kWTAugmentedRealityExperienceArchiveKey_Title];
    [encoder encodeObject:_internalGroupTitle forKey:kWTAugmentedRealityExperienceArchiveKey_Group];
    [encoder encodeObject:_internalURL forKey:kWTAugmentedRealityExperienceArchiveKey_URL];
    [encoder encodeObject:@(_internalRequiredFeatures) forKey:kWTAugmentedRealityExperienceArchiveKey_RequiredFeatures];
    [encoder encodeObject:_internalStartupParameters forKey:kWTAugmentedRealityExperienceArchiveKey_StartupParameters];
    [encoder encodeObject:_internalRequiredViewControllerExtension forKey:kWTAugmentedRealityExperienceArchiveKey_ViewControllerExtension];
}


#pragma mark - Properties

- (NSString *)title
{
    return _internalTitle;
}

- (NSString *)groupTitle
{
    return _internalGroupTitle;
}

- (NSURL *)URL
{
    return _internalURL;
}

- (WTFeatures)requiredFeatures
{
    return _internalRequiredFeatures;
}

- (NSDictionary *)startupParameters
{
    return _internalStartupParameters;
}

- (NSString *)requiredViewControllerExtension
{
    return _internalRequiredViewControllerExtension;
}

@end
