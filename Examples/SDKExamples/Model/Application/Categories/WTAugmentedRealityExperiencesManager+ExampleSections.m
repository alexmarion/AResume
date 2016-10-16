//
//  WTAugmentedRealityExperiencesManager+ExampleSections.m
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 23/09/14.
//  Copyright (c) 2014 Wikitude. All rights reserved.
//

#import "WTAugmentedRealityExperiencesManager+ExampleSections.h"

#import "WTAugmentedRealityExperience.h"



@implementation WTAugmentedRealityExperiencesManager (ExampleSections)


#pragma mark - Public Methods

- (BOOL)hasLoadedAugmentedRealityExperiencesFromPlist
{
    return [self numberOfSections] > 0;
}

- (void)loadAugmentedRealityExperiencesFromPlist:(WTAugmentedRealityExperiencesLoadCompletionHandler)completionHandler
{
    NSURL *examplesPlistURL = [[NSBundle mainBundle] URLForResource:@"Examples" withExtension:@"plist"];
    NSArray *examplesArray = [NSArray arrayWithContentsOfURL:examplesPlistURL];
    
    NSUInteger numberOfExperienceCategories = 0;
    if (examplesPlistURL)
    {
        NSUInteger section = 0;
        for ( NSArray *groupArray in examplesArray )
        {
            for ( NSDictionary *example in groupArray )
            {
                NSString *title = [example objectForKey:@"Title"];
                NSString *groupTitle = [example objectForKey:@"GroupTitle"];
                NSString *relativePath = [example objectForKey:@"Path"];
                WTFeatures requiredFeatures = [self requiredFeaturesFromArray:[example objectForKey:@"RequiredFeatures"]];
                NSDictionary *startupParameters = [example objectForKey:@"StartupConfiguration"];

                NSString *viewControllerExtensionObject = [example objectForKey:@"WTAugmentedRealityViewControllerExtension"];
                NSString *viewControllerExtension = viewControllerExtensionObject ? viewControllerExtensionObject : nil;
                
                NSString *bundleSubdirectory = [[NSString stringWithFormat:@"ARchitectExamples"] stringByAppendingPathComponent:relativePath];                
                NSURL *absoluteURL = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:bundleSubdirectory];
                
                WTAugmentedRealityExperience *experience = [WTAugmentedRealityExperience experienceWithTitle:title groupTitle:groupTitle URL:absoluteURL requiredFeatures:requiredFeatures startupParameters:startupParameters requiredViewControllerExtension:viewControllerExtension];
                [self addAugmentedRealityExperience:experience inSection:section moveToTop:NO];
            }
            
            section++;
        }
        
        numberOfExperienceCategories = section;
    }
    
    if ( completionHandler )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(numberOfExperienceCategories);
        });
    }
}

- (NSString *)exampleGroupTitleForSection:(NSInteger)section
{
    WTAugmentedRealityExperience *experience = [self augmentedRealityExperienceForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return experience.groupTitle;
}

#pragma mark - Private Methods


- (WTFeatures)requiredFeaturesFromArray:(NSArray *)featuresArray
{
    WTFeatures features = 0;
    
    if ( featuresArray )
    {
        for ( NSString *featureString in featuresArray )
        {
            if ( [[featureString lowercaseString] isEqualToString:@"2d_tracking"] )
            {
                features |= WTFeature_2DTracking;
            }
            else if ( [[featureString lowercaseString] isEqualToString:@"geo"] )
            {
                features |= WTFeature_Geo;
            }
        }
    }
    
    return features;
}

@end
