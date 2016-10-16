//
//  FaceDetectionPluginConnector.cpp
//  Native Examples
//
//  Created by Andreas Schacherbauer on 05/08/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#include "FaceDetectionPluginConnector.h"

#import "StrokedRectangle.h"
#import "WTFaceDetectionPluginWrapper.h"


FaceDetectionPluginConnector::FaceDetectionPluginConnector(WTFaceDetectionPluginWrapper *faceDetectionPluginWrapper_) :
_faceDetectionPluginWrapper(faceDetectionPluginWrapper_)
{}

FaceDetectionPluginConnector::~FaceDetectionPluginConnector()
{}

void FaceDetectionPluginConnector::faceDetected(const float *modelViewMatrix) {
    
    [_faceDetectionPluginWrapper setFaceDetected:YES];
    [_faceDetectionPluginWrapper.faceAugmentation setModelViewMatrix:modelViewMatrix];
}

void FaceDetectionPluginConnector::faceLost() {
    
    [_faceDetectionPluginWrapper setFaceDetected:NO];
}

void FaceDetectionPluginConnector::projectionMatrixChanged(const float *projectionMatrix) {

    [_faceDetectionPluginWrapper.faceAugmentation setProjectionMatrix:projectionMatrix];
}

void FaceDetectionPluginConnector::renderDetectedFaceAugmentation() {
    
    if ( [_faceDetectionPluginWrapper faceDetected] ) {
        [_faceDetectionPluginWrapper.faceAugmentation drawInContext:[EAGLContext currentContext]];
    }
}
