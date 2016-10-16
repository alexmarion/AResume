//
//  YUVFrameInputPlugin.cpp
//  DevApplication
//
//  Created by Andreas Schacherbauer on 10/03/16.
//  Copyright © 2016 Wikitude. All rights reserved.
//

#include "YUVFrameInputPlugin.hpp"

#include "WTDeviceCamera.h"
#include "YUVFrameShaderSourceObject.hpp"

#include <fstream>
#include <iostream>
#include <vector>

#define WT_GL_ASSERT( __gl_code__ ) { \
    __gl_code__; \
    GLenum __wt_gl_error_code__ = glGetError(); \
    if ( __wt_gl_error_code__ != GL_NO_ERROR ) { \
        std::cout << "OpenGL error " << __wt_gl_error_code__ << " occured at line " << __LINE__ << " inside function " << __PRETTY_FUNCTION__; \
    } \
}
#define WT_GL_ASSERT_AND_RETURN( __assign_to__, __gl_code__ ) { \
    __assign_to__ = __gl_code__; \
    GLenum __wt_gl_error_code__ = glGetError(); \
    if ( __wt_gl_error_code__ != GL_NO_ERROR ) { \
        std::cout << "OpenGL error " << __wt_gl_error_code__ << " occured at line " << __LINE__ << " inside function " << __PRETTY_FUNCTION__; \
    } \
}

const std::string scanlineVertexShaderSource = "\
attribute vec3 vPosition;\
attribute vec2 vTexCoords;\
\
varying mediump vec2 fTexCoords;\
\
uniform mat4 uModelMatrix;\
\
void main(void)\
{\
    gl_Position = uModelMatrix * vec4(vPosition, 1.0);\
    fTexCoords = vTexCoords;\
}";

const std::string scanlineFragmentShaderSource = "\
uniform lowp sampler2D uCameraFrameTexture;\
uniform mediump vec2 uViewportResolution;\
uniform lowp float uTimeInSeconds;\
uniform lowp float uScanningAreaHeightInPixels;\
\
varying mediump vec2 fTexCoords;\
\
const lowp vec3 rgb2luma = vec3(0.216, 0.7152, 0.0722);\
\
const lowp vec3 ones = vec3(1.0);\
\
const lowp vec3 sobelPositive = vec3(1.0, 2.0, 1.0);\
const lowp vec3 sobelNegative = vec3(-1.0, -2.0, -1.0);\
\
const lowp float animationSpeed = 3.0;\
\
lowp float RGB2Luminance(in lowp vec3 rgb)\
{\
    return dot(rgb2luma * rgb, ones);\
}\
\
void main()\
{\
    mediump vec2 sspPixelSize = vec2(1.0) / uViewportResolution.xy;\
    \
    lowp vec4 cameraFrameColor = texture2D(uCameraFrameTexture, fTexCoords);\
    \
    lowp float tl = RGB2Luminance(texture2D(uCameraFrameTexture, fTexCoords + -sspPixelSize.xy).rgb);\
    lowp float t = RGB2Luminance(texture2D(uCameraFrameTexture, fTexCoords + vec2(0.0, -sspPixelSize.y)).rgb);\
    lowp float tr = RGB2Luminance(texture2D(uCameraFrameTexture, fTexCoords + vec2(sspPixelSize.x, -sspPixelSize.y)).rgb);\
    \
    lowp float cl = RGB2Luminance(texture2D(uCameraFrameTexture, fTexCoords + vec2(-sspPixelSize.x, 0.0)).rgb);\
    lowp float c = RGB2Luminance(cameraFrameColor.rgb);\
    lowp float cr = RGB2Luminance(texture2D(uCameraFrameTexture, fTexCoords + vec2(sspPixelSize.x, 0.0)).rgb);\
    \
    lowp float bl = RGB2Luminance(texture2D(uCameraFrameTexture, fTexCoords + vec2(-sspPixelSize.x, sspPixelSize.y)).rgb);\
    lowp float b = RGB2Luminance(texture2D(uCameraFrameTexture, fTexCoords + vec2(0.0, sspPixelSize.y)).rgb);\
    lowp float br = RGB2Luminance(texture2D(uCameraFrameTexture, fTexCoords + vec2(sspPixelSize.x, sspPixelSize.y)).rgb);\
    \
    lowp float sobelX = dot(sobelNegative * vec3(tl, cl, bl) + sobelPositive * vec3(tr, cr, br), ones);\
    lowp float sobelY = dot(sobelNegative * vec3(tl, t, tr) + sobelPositive * vec3(bl, b, br), ones);\
    \
    lowp float sobel = length(vec2(sobelX, sobelY));\
    \
    mediump float sspScanlineY = sin(uTimeInSeconds * animationSpeed) * 0.5 + 0.5;\
    mediump float sspFragmentCenterY = gl_FragCoord.y / uViewportResolution.y;\
    \
    lowp float sspScanWindowHeight = uScanningAreaHeightInPixels * sspPixelSize.y;\
    \
    mediump float distanceToScanline = clamp(0.0, sspScanWindowHeight, distance(sspScanlineY, sspFragmentCenterY)) / sspScanWindowHeight;\
    \
    gl_FragColor = vec4(mix(mix(vec3(c), vec3(1.0, 0.549, 0.0392), step(0.15, sobel)), cameraFrameColor.rgb, smoothstep(0.3, 0.7, distanceToScanline)), 1.0);\
}";

const std::string fullscreenTextureFragmentShader = "\
uniform lowp sampler2D uCameraFrameTexture;\
\
varying mediump vec2 fTexCoords;\
\
void main() {\
    gl_FragColor = vec4(texture2D(uCameraFrameTexture, fTexCoords).rgb, 1.0);\
}";

const std::string augmentationVertexShaderSource = "\
uniform mat4 uModelViewProjectionMatrix;\
\
attribute vec3 vPosition;\
attribute vec2 vTexCoords;\
\
varying mediump vec2 fTexCoords;\
\
void main() {\
    gl_Position = uModelViewProjectionMatrix * vec4(vPosition, 1.0);\
    fTexCoords = vTexCoords;\
}";

const std::string augmentationFragmentShaderSource = "\
varying mediump vec2 fTexCoords;\
\
void main()\
{\
    gl_FragColor = vec4(vec3(1.0, 0.549, 0.0392), 1.0);\
}";

YUVFrameInputPlugin::YUVFrameInputPlugin(__weak WTDeviceCamera* camera_)
:
InputPlugin("com.wikitude.plugin.customcamera"),
_frameId(0),
_camera(camera_),
_renderingInitialized(false),
_surfaceInitialized(false),
_scanlineShaderHandle(0),
_fullscreenTextureShader(0),
_augmentationShaderHandle(0),
_programHandle(0),
_vertexBuffer(0),
_indexBuffer(0),
_positionAttributeLocation(0),
_texCoordAttributeLocation(0),
_lumaTexture(0),
_chromaTexture(0),
_frameBufferObject(0),
_frameBufferTexture(0),
_defaultFrameBuffer(0),
_indices{0, 1, 2, 2, 3, 0}
{
    startTime = std::chrono::system_clock::now();
    
    _fboCorrectionMatrix.scale(1.0f, -1.0f, 1.0f);
}

YUVFrameInputPlugin::~YUVFrameInputPlugin()
{
    releaseFramebufferObject();
    releaseShaderProgram();
    releaseVertexBuffers();
    releaseFrameTextures();
}

void YUVFrameInputPlugin::initialize() {
    _initialized = [_camera initialize];
}

void YUVFrameInputPlugin::pause() {
    [_camera stopRunning];
    _running = false;
    
    releaseFramebufferObject();
    releaseFrameTextures();
    releaseVertexBuffers();
    releaseShaderProgram();

    _renderingInitialized = false;
}

void YUVFrameInputPlugin::resume(unsigned int pausedTime_) {
    if ( _initialized ) {
        _running = [_camera startRunning];
    }
}

void YUVFrameInputPlugin::destroy() {
    [_camera shutdown];
}

void YUVFrameInputPlugin::startRender() {
    if (!_renderingInitialized.load()) {
        _renderingInitialized.store(setupRendering());
    }

    render();
}

void YUVFrameInputPlugin::endRender() {

}

void YUVFrameInputPlugin::surfaceChanged(wikitude::sdk::Size<int> renderSurfaceSize_, wikitude::sdk::Size<float> cameraSurfaceScaling_, wikitude::sdk::InterfaceOrientation interfaceOrientation_) {
    wikitude::sdk::Matrix4 scaleMatrix;
    scaleMatrix.scale(cameraSurfaceScaling_.width, cameraSurfaceScaling_.height, 1.0f);
    
    switch (interfaceOrientation_)
    {
        case wikitude::sdk::InterfaceOrientation::InterfaceOrientationPortrait:
        {
            wikitude::sdk::Matrix4 rotationToPortrait;
            rotationToPortrait.rotateZ(270.0f);
            
            _orientationMatrix = rotationToPortrait;
            break;
        }
        case wikitude::sdk::InterfaceOrientation::InterfaceOrientationPortraitUpsideDown:
        {
            wikitude::sdk::Matrix4 rotationToUpsideDown;
            rotationToUpsideDown.rotateZ(90.0f);
            
            _orientationMatrix = rotationToUpsideDown;
            break;
        }
        case wikitude::sdk::InterfaceOrientation::InterfaceOrientationLandscapeLeft:
        {
            wikitude::sdk::Matrix4 rotationToLandscapeLeft;
            rotationToLandscapeLeft.rotateZ(180.0f);
            
            _orientationMatrix = rotationToLandscapeLeft;
            break;
        }
        case wikitude::sdk::InterfaceOrientation::InterfaceOrientationLandscapeRight:
        {
            _orientationMatrix.identity();
            break;
        }
    }
    
    _modelMatrix = scaleMatrix * _orientationMatrix * _fboCorrectionMatrix;
    
    _surfaceInitialized.store(true);
}

// from InputPlugin
wikitude::sdk::FrameColorSpace YUVFrameInputPlugin::getInputFrameColorSpace() {
    return wikitude::sdk::FrameColorSpace::YUV_420_NV21;
}

float YUVFrameInputPlugin::getHorizontalAngle() {
    return [_camera fieldOfView];
}

wikitude::sdk::Size<int> YUVFrameInputPlugin::getInputFrameSize() {
    return {[_camera videoDimensions].width, [_camera videoDimensions].height};
}

bool YUVFrameInputPlugin::requestsInputFrameRendering() {
    return false;
}

bool YUVFrameInputPlugin::requestsInputFrameProcessing() {
    return true;
}

bool YUVFrameInputPlugin::allowsUsageByOtherPlugins() {
    return true;
}

void YUVFrameInputPlugin::notifyNewImageBufferData(std::shared_ptr<unsigned char> imageBufferData) {
    notifyNewInputFrame(++_frameId, imageBufferData);
}

void YUVFrameInputPlugin::update(const std::list<wikitude::sdk::RecognizedTarget>& recognizedTargets_) {
    std::lock_guard<std::mutex> lock(_currentlyRecognizedTargetsMutex);
    _currentlyRecognizedTargets = std::list<wikitude::sdk::RecognizedTarget>(recognizedTargets_);
}

bool YUVFrameInputPlugin::setupRendering() {
    _vertices[0] = (Vertex){{1.0f, -1.0f, 0}, {1.0f, 0.0f}};
    _vertices[1] = (Vertex){{1.0f, 1.0f, 0}, {1.0f, 1.0f}};
    _vertices[2] = (Vertex){{-1.0f, 1.0f, 0}, {0.0f, 1.0f}};
    _vertices[3] = (Vertex){{-1.0f, -1.0f, 0}, {0.0f, 0.0f}};

    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &_defaultFrameBuffer);
    
    _scanlineShaderHandle = createShaderProgram(scanlineVertexShaderSource, scanlineFragmentShaderSource);
    _fullscreenTextureShader = createShaderProgram(scanlineVertexShaderSource, fullscreenTextureFragmentShader);
    _augmentationShaderHandle = createShaderProgram(augmentationVertexShaderSource, augmentationFragmentShaderSource);
    createShaderProgram(YUVFrameShaderSourceObject());
    createVertexBuffers();
    createFrameTextures([_camera videoDimensions].width, [_camera videoDimensions].height);
    createFrameBufferObject([_camera videoDimensions].width, [_camera videoDimensions].height);
    
    return true;
}

void YUVFrameInputPlugin::render() {
    
    if (!_renderingInitialized.load()) {
        std::cout << "Rendering not initialized. Skipping render() function." << std::endl;
        return;
    }
    
    if (!_surfaceInitialized.load()) {
        return;
    }
    
    { // shared_ptr auto release scope
        std::shared_ptr<unsigned char> presentableFrameData = getPresentableInputFrameData();
        if (presentableFrameData) {
            updateFrameTexturesData([_camera videoDimensions].width, [_camera videoDimensions].height, presentableFrameData.get());
        }
    }
    
    WT_GL_ASSERT(glDisable(GL_DEPTH_TEST));
    
    WT_GL_ASSERT(glUseProgram(_programHandle));
    
    WT_GL_ASSERT(glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer));
    WT_GL_ASSERT(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer));
    
    WT_GL_ASSERT(glEnableVertexAttribArray(_positionAttributeLocation));
    WT_GL_ASSERT(glEnableVertexAttribArray(_texCoordAttributeLocation));
    
    WT_GL_ASSERT(glVertexAttribPointer(_positionAttributeLocation, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0));
    WT_GL_ASSERT(glVertexAttribPointer(_texCoordAttributeLocation, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float) * 3)));
    
    bindFrameTextures();
    
    bindFrameBufferObject();

    GLint viewport[4];
    glGetIntegerv(GL_VIEWPORT, viewport);
    
    const float viewportWidth = viewport[2] - viewport[0];
    const float viewportHeight = viewport[3] - viewport[1];
    
    WT_GL_ASSERT(glViewport(0, 0, [_camera videoDimensions].width, [_camera videoDimensions].height));
    WT_GL_ASSERT(glClear(GL_COLOR_BUFFER_BIT));
    WT_GL_ASSERT(glDrawElements(GL_TRIANGLES, sizeof(_indices)/sizeof(_indices[0]), GL_UNSIGNED_SHORT, 0));
    unbindFrameBufferObject();
    
    WT_GL_ASSERT(glViewport(viewport[0], viewport[1], viewport[2], viewport[3]));
    
    WT_GL_ASSERT(glClear(GL_COLOR_BUFFER_BIT));
    
    WT_GL_ASSERT(glActiveTexture(GL_TEXTURE0));
    WT_GL_ASSERT(glBindTexture(GL_TEXTURE_2D, _frameBufferTexture));
    
    { // mutex auto release scope
        std::unique_lock<std::mutex> lock(_currentlyRecognizedTargetsMutex);
    
        if (!_currentlyRecognizedTargets.empty()) {
            
            // just use one of the targets found, should be sufficient to get the point across
            const wikitude::sdk::RecognizedTarget targetToDraw = _currentlyRecognizedTargets.front();
            
            // early unlock to minimize locking duration
            lock.unlock();
            
            WT_GL_ASSERT(glUseProgram(_fullscreenTextureShader));
            setVertexShaderUniforms(_fullscreenTextureShader);
            
            GLint fullscreenTextureUniformLocation;
            WT_GL_ASSERT_AND_RETURN(fullscreenTextureUniformLocation, glGetUniformLocation(_fullscreenTextureShader, "uCameraFrameTexture"));
            WT_GL_ASSERT(glUniform1i(fullscreenTextureUniformLocation, 0));
            
            setVertexAttributes(_fullscreenTextureShader);
            
            WT_GL_ASSERT(glDrawElements(GL_TRIANGLES, sizeof(_indices)/sizeof(_indices[0]), GL_UNSIGNED_SHORT, 0));
            
            const float TARGET_HEIGHT_IN_PIXELS = 320.0f;
            
            // TODO: can be computed in the ctor
            wikitude::sdk::Matrix4 toSizeInPixelsScaling;
            // scaled to be able to re-use the screen aligned quad (side length = 2) and thus
            // avoid having to create additional vertex data and correspondig code
            toSizeInPixelsScaling.scale(0.5f, 0.5f, 1.0f);
            
            toSizeInPixelsScaling.scale(TARGET_HEIGHT_IN_PIXELS, TARGET_HEIGHT_IN_PIXELS, 1.0f);
            
            wikitude::sdk::Matrix4 modelView = targetToDraw.getModelViewMatrix();
            wikitude::sdk::Matrix4 projection = targetToDraw.getProjectionMatrix();
            
            wikitude::sdk::Matrix4 modelViewProjection = projection * modelView * toSizeInPixelsScaling;
            
            WT_GL_ASSERT(glUseProgram(_augmentationShaderHandle));
            GLint modelViewProjectionLocation;
            WT_GL_ASSERT_AND_RETURN(modelViewProjectionLocation, glGetUniformLocation(_augmentationShaderHandle, "uModelViewProjectionMatrix"));
            WT_GL_ASSERT(glUniformMatrix4fv(modelViewProjectionLocation, 1, GL_FALSE, modelViewProjection.get()));
            
            setVertexAttributes(_augmentationShaderHandle);
            
            WT_GL_ASSERT(glDrawElements(GL_TRIANGLES, sizeof(_indices)/sizeof(_indices[0]), GL_UNSIGNED_SHORT, 0));
        }
        else {
            WT_GL_ASSERT(glUseProgram(_scanlineShaderHandle));
            setVertexShaderUniforms(_scanlineShaderHandle);
            
            setFragmentShaderUniforms(viewportWidth, viewportHeight);
            setVertexAttributes(_scanlineShaderHandle);
            
            WT_GL_ASSERT(glDrawElements(GL_TRIANGLES, sizeof(_indices)/sizeof(_indices[0]), GL_UNSIGNED_SHORT, 0));
        }
    }
    
    WT_GL_ASSERT(glBindBuffer(GL_ARRAY_BUFFER, 0));
    WT_GL_ASSERT(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0));

    WT_GL_ASSERT(glUseProgram(0));

    WT_GL_ASSERT(glEnable(GL_DEPTH_TEST));
}

void YUVFrameInputPlugin::createVertexBuffers()
{
    WT_GL_ASSERT(glGenBuffers(1, &_vertexBuffer));
    WT_GL_ASSERT(glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer));
    WT_GL_ASSERT(glBufferData(GL_ARRAY_BUFFER, 4 * sizeof(Vertex), &_vertices, GL_STATIC_DRAW));

    WT_GL_ASSERT(glGenBuffers(1, &_indexBuffer));
    WT_GL_ASSERT(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer));
    WT_GL_ASSERT(glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(_indices), _indices, GL_STATIC_DRAW));
}

void YUVFrameInputPlugin::releaseVertexBuffers()
{
    if (_vertexBuffer) {
        WT_GL_ASSERT(glDeleteBuffers(1, &_vertexBuffer));
        _vertexBuffer = 0;
    }

    if (_indexBuffer) {
        WT_GL_ASSERT(glDeleteBuffers(1, &_indexBuffer));
        _vertexBuffer = 0;
    }
}

GLuint YUVFrameInputPlugin::compileShader(const std::string& shaderSource, const GLenum shaderType)
{
    GLuint shaderHandle;
    WT_GL_ASSERT_AND_RETURN(shaderHandle, glCreateShader(shaderType));

    const char* shaderString = shaderSource.c_str();
    GLint shaderStringLength = static_cast<GLint>(shaderSource.length());

    WT_GL_ASSERT(glShaderSource(shaderHandle, 1, &shaderString, &shaderStringLength));
    WT_GL_ASSERT(glCompileShader(shaderHandle));

    GLint compileSuccess;
    WT_GL_ASSERT(glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess));
    if (GL_FALSE == compileSuccess)
    {
        GLchar messages[256];
        WT_GL_ASSERT(glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]));
        std::cout << "Error compiling shader: " << messages << std::endl;
    }

    return shaderHandle;
}

GLuint YUVFrameInputPlugin::createShaderProgram(const std::string& vertexShaderSource, const std::string& fragmentShaderSource)
{
    GLuint vertexShaderHandle = compileShader(vertexShaderSource, GL_VERTEX_SHADER);
    GLuint fragmentShaderHandle = compileShader(fragmentShaderSource, GL_FRAGMENT_SHADER);
    
    GLuint programHandle;
    WT_GL_ASSERT_AND_RETURN(programHandle, glCreateProgram());

    WT_GL_ASSERT(glAttachShader(programHandle, vertexShaderHandle));
    WT_GL_ASSERT(glAttachShader(programHandle, fragmentShaderHandle));
    WT_GL_ASSERT(glLinkProgram(programHandle));
    
    GLint linkSuccess;
    WT_GL_ASSERT(glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess));
    if (linkSuccess == GL_FALSE)
    {
        GLchar messages[256];
        WT_GL_ASSERT(glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]));
        std::cout << "Error linking program: " << messages << std::endl;
    }
    
    WT_GL_ASSERT(glDeleteShader(vertexShaderHandle));
    WT_GL_ASSERT(glDeleteShader(fragmentShaderHandle));
    
    return programHandle;
}

void YUVFrameInputPlugin::createShaderProgram(const YUVFrameShaderSourceObject& shaderObject)
{
    _programHandle = createShaderProgram(shaderObject.getVertexShaderSource(), shaderObject.getFragmentShaderSource());
    
    WT_GL_ASSERT(glUseProgram(_programHandle));

    WT_GL_ASSERT_AND_RETURN(_positionAttributeLocation, glGetAttribLocation(_programHandle, shaderObject.getVertexPositionAttributeName().c_str()));
    WT_GL_ASSERT_AND_RETURN(_texCoordAttributeLocation, glGetAttribLocation(_programHandle, shaderObject.getTextureCoordinateAttributeName().c_str()));

    std::vector<std::string> uniformNames = shaderObject.getTextureUniformNames();
    std::size_t uniformNamesSize = uniformNames.size();
    for (int i = 0; i < uniformNamesSize; ++i)
    {
        WT_GL_ASSERT(glUniform1i(glGetUniformLocation(_programHandle, uniformNames[i].c_str()), i));
    }
}

void YUVFrameInputPlugin::releaseShaderProgram()
{
    if (_scanlineShaderHandle) {
        WT_GL_ASSERT(glDeleteProgram(_scanlineShaderHandle));
        _scanlineShaderHandle = 0;
    }
    
    if (_fullscreenTextureShader) {
        WT_GL_ASSERT(glDeleteProgram(_fullscreenTextureShader));
        _fullscreenTextureShader = 0;
    }
    
    if (_augmentationShaderHandle) {
        WT_GL_ASSERT(glDeleteProgram(_augmentationShaderHandle));
        _augmentationShaderHandle = 0;
    }
    
    if (_programHandle) {
        WT_GL_ASSERT(glDeleteProgram(_programHandle));
        _programHandle = 0;
    }
}

void YUVFrameInputPlugin::setVertexShaderUniforms(GLuint shaderHandle)
{
    GLint deviceOrientationLocation;
    WT_GL_ASSERT_AND_RETURN(deviceOrientationLocation, glGetUniformLocation(shaderHandle, "uModelMatrix"));
    WT_GL_ASSERT(glUniformMatrix4fv(deviceOrientationLocation, 1, GL_FALSE, _modelMatrix.get()));
}

void YUVFrameInputPlugin::setFragmentShaderUniforms(float viewportWidth, float viewportHeight)
{
    GLint scanlineUniformLocation;
    WT_GL_ASSERT_AND_RETURN(scanlineUniformLocation, glGetUniformLocation(_scanlineShaderHandle, "uCameraFrameTexture"));
    WT_GL_ASSERT(glUniform1i(scanlineUniformLocation, 0));
    
    GLint scanlineUniformResolutionLocation;
    WT_GL_ASSERT_AND_RETURN(scanlineUniformResolutionLocation, glGetUniformLocation(_scanlineShaderHandle, "uViewportResolution"));
    WT_GL_ASSERT(glUniform2f(scanlineUniformResolutionLocation, viewportWidth, viewportHeight));
    
    currentTime = std::chrono::system_clock::now();
    std::chrono::duration<float> durationInSeconds = currentTime - startTime;
    GLint scanlineUniformTimeLocation;
    WT_GL_ASSERT_AND_RETURN(scanlineUniformTimeLocation, glGetUniformLocation(_scanlineShaderHandle, "uTimeInSeconds"));
    WT_GL_ASSERT(glUniform1f(scanlineUniformTimeLocation, durationInSeconds.count()));
    
    const float scanningAreaHeight = viewportHeight * 0.25;
    
    GLint scanlineUniformAreaHeight;
    WT_GL_ASSERT_AND_RETURN(scanlineUniformAreaHeight, glGetUniformLocation(_scanlineShaderHandle, "uScanningAreaHeightInPixels"));
    WT_GL_ASSERT(glUniform1f(scanlineUniformAreaHeight, scanningAreaHeight));
}

void YUVFrameInputPlugin::setVertexAttributes(GLuint shaderHandle)
{
    GLint vertexPositionAttributeLocation;
    WT_GL_ASSERT_AND_RETURN(vertexPositionAttributeLocation, glGetAttribLocation(shaderHandle, "vPosition"));
    WT_GL_ASSERT(glEnableVertexAttribArray(vertexPositionAttributeLocation));
    WT_GL_ASSERT(glVertexAttribPointer(vertexPositionAttributeLocation, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0));
    
    GLint vertexTexCoordAttributeLocation;
    WT_GL_ASSERT_AND_RETURN(vertexTexCoordAttributeLocation, glGetAttribLocation(shaderHandle, "vTexCoords"));
    WT_GL_ASSERT(glEnableVertexAttribArray(vertexTexCoordAttributeLocation));
    WT_GL_ASSERT(glVertexAttribPointer(vertexTexCoordAttributeLocation, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float) * 3)));
}

void YUVFrameInputPlugin::createFrameTextures(GLsizei width, GLsizei height)
{
    WT_GL_ASSERT(glGenTextures(1, &_lumaTexture));
    WT_GL_ASSERT(glGenTextures(1, &_chromaTexture));

    WT_GL_ASSERT(glActiveTexture(GL_TEXTURE0));
    WT_GL_ASSERT(glBindTexture(GL_TEXTURE_2D, _lumaTexture));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE));

    WT_GL_ASSERT(glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, width, height, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, nullptr));

    WT_GL_ASSERT(glBindTexture(GL_TEXTURE_2D, _chromaTexture));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE));

    WT_GL_ASSERT(glTexImage2D(GL_TEXTURE_2D, 0, GL_RG_EXT, width / 2, height / 2, 0, GL_RG_EXT, GL_UNSIGNED_BYTE, nullptr));
}

void YUVFrameInputPlugin::updateFrameTexturesData(GLsizei width, GLsizei height, const unsigned char* const frameData)
{
    WT_GL_ASSERT(glActiveTexture(GL_TEXTURE0));

    WT_GL_ASSERT(glBindTexture(GL_TEXTURE_2D, _lumaTexture));
    WT_GL_ASSERT(glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, width, height, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, frameData));

    WT_GL_ASSERT(glBindTexture(GL_TEXTURE_2D, _chromaTexture));
    WT_GL_ASSERT(glTexImage2D(GL_TEXTURE_2D, 0, GL_RG_EXT, width / 2, height / 2, 0, GL_RG_EXT, GL_UNSIGNED_BYTE, frameData + width * height));
}

void YUVFrameInputPlugin::bindFrameTextures()
{
    WT_GL_ASSERT(glActiveTexture(GL_TEXTURE0));
    WT_GL_ASSERT(glBindTexture(GL_TEXTURE_2D, _lumaTexture));

    WT_GL_ASSERT(glActiveTexture(GL_TEXTURE1));
    WT_GL_ASSERT(glBindTexture(GL_TEXTURE_2D, _chromaTexture));
}

void YUVFrameInputPlugin::releaseFrameTextures()
{
    if (_lumaTexture) {
        WT_GL_ASSERT(glDeleteTextures(1, &_lumaTexture));
        _lumaTexture = 0;
    }

    if (_chromaTexture) {
        WT_GL_ASSERT(glDeleteTextures(1, &_chromaTexture));
        _chromaTexture = 0;
    }
}

void YUVFrameInputPlugin::createFrameBufferObject(GLsizei width, GLsizei height)
{
    WT_GL_ASSERT(glGenFramebuffers(1, &_frameBufferObject));
    WT_GL_ASSERT(glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferObject));

    WT_GL_ASSERT(glGenTextures(1, &_frameBufferTexture));

    WT_GL_ASSERT(glActiveTexture(GL_TEXTURE0));
    WT_GL_ASSERT(glBindTexture(GL_TEXTURE_2D, _frameBufferTexture));

    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE));
    WT_GL_ASSERT(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE));

    WT_GL_ASSERT(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, nullptr));

    WT_GL_ASSERT(glBindTexture(GL_TEXTURE_2D, 0));
    
    WT_GL_ASSERT(glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _frameBufferTexture, 0));

    GLenum framebufferStatus;
    WT_GL_ASSERT_AND_RETURN(framebufferStatus, glCheckFramebufferStatus(GL_FRAMEBUFFER));
    
    switch (framebufferStatus)
    {
        case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
            std::cout << "GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT" << std::endl;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            std::cout << "GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT" << std::endl;
            break;
        case GL_FRAMEBUFFER_UNSUPPORTED:
            std::cout << "GL_FRAMEBUFFER_UNSUPPORTED" << std::endl;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
            std::cout << "GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS" << std::endl;
            break;
    }
    
    if (framebufferStatus != GL_FRAMEBUFFER_COMPLETE) {
        std::cout << "Framebuffer incomplete!" << std::endl;
    }
}

void YUVFrameInputPlugin::bindFrameBufferObject()
{
    WT_GL_ASSERT(glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferObject));
}

void YUVFrameInputPlugin::unbindFrameBufferObject()
{
    WT_GL_ASSERT(glBindFramebuffer(GL_FRAMEBUFFER, _defaultFrameBuffer));
}

void YUVFrameInputPlugin::releaseFramebufferObject()
{
    if (_frameBufferTexture) {
        WT_GL_ASSERT(glDeleteTextures(1, &_frameBufferTexture));
        _frameBufferTexture = 0;
    }

    if (_frameBufferObject) {
        WT_GL_ASSERT(glDeleteTextures(1, &_frameBufferObject));
        _frameBufferObject = 0;
    }
}
