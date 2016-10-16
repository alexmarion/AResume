//
//  YUVFrameInputPlugin.hpp
//  DevApplication
//
//  Created by Andreas Schacherbauer on 10/03/16.
//  Copyright © 2016 Wikitude. All rights reserved.
//

#ifndef YUVFrameInputPlugin_hpp
#define YUVFrameInputPlugin_hpp

#include <atomic>
#include <chrono>
#include <mutex>
#include <string>
#include <list>

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include <WikitudeSDK/Frame.h>
#include <WikitudeSDK/InputPlugin.h>
#include <WikitudeSDK/Matrix4.h>
#include <WikitudeSDK/RecognizedTarget.h>

#include "YUVFrameShaderSourceObject.hpp"


@class WTDeviceCamera;

class YUVFrameInputPlugin : public wikitude::sdk::InputPlugin {
    
public:
    YUVFrameInputPlugin(__weak WTDeviceCamera* camera_);
    virtual ~YUVFrameInputPlugin();

    // from Plugin
    void initialize();
    void pause();
    void resume(unsigned int pausedTime_);
    void destroy();
    void startRender();
    void endRender();
    
    void surfaceChanged(wikitude::sdk::Size<int> renderSurfaceSize_, wikitude::sdk::Size<float> cameraSurfaceScaling_, wikitude::sdk::InterfaceOrientation interfaceOrientation_);

    // from InputPlugin
    wikitude::sdk::FrameColorSpace getInputFrameColorSpace();
    float getHorizontalAngle();
    wikitude::sdk::Size<int> getInputFrameSize();

    bool requestsInputFrameRendering();
    bool requestsInputFrameProcessing();
    bool allowsUsageByOtherPlugins();

    void notifyNewImageBufferData(std::shared_ptr<unsigned char> imageBufferData);
    
    void update(const std::list<wikitude::sdk::RecognizedTarget>& recognizedTargets_);
    
protected:
    long                    _frameId;
    __weak WTDeviceCamera*  _camera;

    bool                    _initialized;
    bool                    _running;
    
private:
    static const int CAMERA_FRAME_WIDTH = 640;
    static const int CAMERA_FRAME_HEIGHT = 480;
    
    bool setupRendering();
    void render();
    
    void createVertexBuffers();
    void releaseVertexBuffers();
    
    GLuint compileShader(const std::string& shaderSource, const GLenum shaderType);
    GLuint createShaderProgram(const std::string& vertexShaderSource, const std::string& fragmentShaderSource);
    void createShaderProgram(const YUVFrameShaderSourceObject& shaderObject);
    void releaseShaderProgram();
    
    void setVertexShaderUniforms(GLuint shaderHandle);
    void setFragmentShaderUniforms(float viewportWidth, float viewportHeight);
    void setVertexAttributes(GLuint shaderHandle);
    
    void createFrameTextures(GLsizei width, GLsizei height);
    void updateFrameTexturesData(GLsizei width, GLsizei height, const unsigned char* const frameData);
    void bindFrameTextures();
    void releaseFrameTextures();
    
    void createFrameBufferObject(GLsizei width, GLsizei height);
    void bindFrameBufferObject();
    void unbindFrameBufferObject();
    void releaseFramebufferObject();
    
    std::atomic_bool _renderingInitialized;
    std::atomic_bool _surfaceInitialized;
    
    GLuint _scanlineShaderHandle;
    GLuint _fullscreenTextureShader;
    GLuint _augmentationShaderHandle;
    
    GLuint _programHandle;
    
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    
    GLuint _positionAttributeLocation;
    GLuint _texCoordAttributeLocation;
    
    GLuint _lumaTexture;
    GLuint _chromaTexture;
    
    GLint _defaultFrameBuffer;
    GLuint _frameBufferObject;
    GLuint _frameBufferTexture;
    
    struct Vertex
    {
        GLfloat position[3];
        GLfloat texCoord[2];
    };
    
    Vertex _vertices[4];
    
    const GLushort _indices[6];
    
    wikitude::sdk::Matrix4 _orientationMatrix;
    wikitude::sdk::Matrix4 _fboCorrectionMatrix;
    wikitude::sdk::Matrix4 _modelMatrix;
    
    std::chrono::time_point<std::chrono::system_clock> startTime;
    std::chrono::time_point<std::chrono::system_clock> currentTime;
    
    std::mutex _currentlyRecognizedTargetsMutex;
    std::list<wikitude::sdk::RecognizedTarget> _currentlyRecognizedTargets;
};

#endif /* YUVFrameInputPlugin_hpp */
