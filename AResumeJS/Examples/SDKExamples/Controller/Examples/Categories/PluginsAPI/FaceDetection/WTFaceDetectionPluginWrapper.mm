//
//  WTFaceDetectionPluginWrapper.m
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 07/08/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#import "WTFaceDetectionPluginWrapper.h"

#import "WTAugmentedRealityViewController+PluginLoading.h"
#import "StrokedRectangle.h"


@implementation WTFaceDetectionPluginWrapper

- (instancetype)init
{
    self = [super init];
    if (self)
    {
#ifndef SIMULATOR_BUILD
        std::string databasePath([[[NSBundle mainBundle] pathForResource:@"high_database" ofType:@"xml" inDirectory:@"ARchitectExamples/9_PluginsAPI_2_FaceDetection/assets"] UTF8String]);
        _faceDetectionPluginConnector = std::make_shared<FaceDetectionPluginConnector>(self);
        _faceDetectionPlugin = std::make_shared<FaceDetectionPlugin>([kWTPluginIdentifier_FacedetectionPlugin cStringUsingEncoding:NSUTF8StringEncoding], 640, 480, databasePath, *_faceDetectionPluginConnector.get());
#endif
        _faceAugmentation = [[StrokedRectangle alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start
{
    [_faceAugmentation setEnabled:YES];
}

- (void)stop
{
    [_faceAugmentation setEnabled:NO];
    [_faceAugmentation reset];
}

@end
