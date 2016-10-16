//
//  WTFaceDetectionPluginWrapper.h
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 07/08/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef SIMULATOR_BUILD
#include "FaceDetectionPlugin.h"
#include "FaceDetectionPluginConnector.h"
#endif

@class StrokedRectangle;

@interface WTFaceDetectionPluginWrapper : NSObject

#ifndef SIMULATOR_BUILD
@property (nonatomic, assign) std::shared_ptr<FaceDetectionPluginConnector>             faceDetectionPluginConnector;
@property (nonatomic, assign) std::shared_ptr<FaceDetectionPlugin>                      faceDetectionPlugin;
#endif

@property (nonatomic, assign) BOOL                                                      faceDetected;

@property (nonatomic, strong) StrokedRectangle                                          *faceAugmentation;

- (instancetype)init;

- (void)start;
- (void)stop;

@end
