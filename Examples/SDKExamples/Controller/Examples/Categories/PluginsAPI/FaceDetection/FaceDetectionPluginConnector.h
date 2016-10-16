//
//  FaceDetectionPluginConnector.h
//  Native Examples
//
//  Created by Andreas Schacherbauer on 05/08/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#ifndef __Native_Examples__FaceDetectionPluginConnector__
#define __Native_Examples__FaceDetectionPluginConnector__


#include "FaceDetectionPlugin.h"


@class WTFaceDetectionPluginWrapper;
class FaceDetectionPluginConnector : public FaceDetectionPluginObserver {

public:
    FaceDetectionPluginConnector(WTFaceDetectionPluginWrapper *faceDetectionPluginWrapper_);
    virtual ~FaceDetectionPluginConnector();
    
    virtual void faceDetected(const float* modelViewMatrix);
    virtual void faceLost();
    
    virtual void projectionMatrixChanged(const float* projectionMatrix);
    
    virtual void renderDetectedFaceAugmentation();
    
protected:
    __weak WTFaceDetectionPluginWrapper            *_faceDetectionPluginWrapper;
};

#endif /* defined(__Native_Examples__FaceDetectionPluginConnector__) */
