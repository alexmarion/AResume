//
//  FaceDetectionPlugin.h
//  Native Examples
//
//  Created by Alami Yacine on 29/07/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#ifndef __DevApplication__FaceDetectionPlugin__
#define __DevApplication__FaceDetectionPlugin__

#include <iostream>
#include <mutex>
#include <sstream>
#include <vector>

#include <opencv.hpp>

#import <WikitudeSDK/Plugin.h>
#import <WikitudeSDK/Frame.h>
#import <WikitudeSDK/RecognizedTarget.h>


class FaceDetectionPluginObserver {
public:
    virtual ~FaceDetectionPluginObserver() {}
    
    virtual void faceDetected(const float* modelViewMatrix) = 0;
    virtual void faceLost() = 0;
    virtual void projectionMatrixChanged(const float* projectionMatrix) = 0;
    
    virtual void renderDetectedFaceAugmentation() = 0;
};

#ifndef SIMULATOR_BUILD
class FaceDetectionPlugin : public wikitude::sdk::Plugin {
    
public:
    
    FaceDetectionPlugin(const std::string& pluginIdentifier, int cameraFrameWidth_, int cameraFrameHeight_, std::string databasePath_, FaceDetectionPluginObserver& observer_);
    
    virtual ~FaceDetectionPlugin();
    
    virtual void initialize();
    virtual void destroy();
    virtual void cameraFrameAvailable(const wikitude::sdk::Frame& cameraFrame_);
    virtual void update(const std::list<wikitude::sdk::RecognizedTarget>& recognizedTargets_);
    virtual void surfaceChanged(wikitude::sdk::Size<int> renderSurfaceSize_, wikitude::sdk::Size<float> cameraSurfaceScaling_, wikitude::sdk::InterfaceOrientation interfaceOrientation_);
    
    virtual void startRender();
    
    inline bool isLoaded(){ return _isDatabaseLoaded; };
    
protected:
    void convertFaceRectToModelViewMatrix(cv::Mat& frame_, cv::Rect& faceRect_, wikitude::sdk::InterfaceOrientation interfaceOrientation_);
    void calculateProjection(wikitude::sdk::InterfaceOrientation interfaceOrientation_, float left, float right, float bottom, float top, float near, float far);
    
protected:
    
    std::string                             _databasePath;
    bool                                    _isDatabaseLoaded;
    
    cv::Mat                                 _grayFrame;
    
    cv::CascadeClassifier                   _cascadeDetector;
    std::vector<cv::Rect>                   _result;
    
    int                                     _cameraFrameWidth;
    int                                     _cameraFrameHeight;

    float                                   _scaledCameraFrameWidth;
    float                                   _scaledCameraFrameHeight;

    float                                   _modelViewMatrix[16];
    float                                   _projectionMatrix[16];
    
    float                                   _aspectRatio;
    
    std::mutex                              _interfaceOrientationMutex;
    wikitude::sdk::InterfaceOrientation     _interfaceOrientation;
    
    FaceDetectionPluginObserver&            _observer;
};
#endif
#endif /* defined(__DevApplication__FaceDetectionPlugin__) */
