# Wikitude SDK iOS Release Notes

## Wikitude SDK JavaScript API 5.3.0
Release Date: 13.09.2016

#### New
###### SDK
- iOS 10 support
- Positionables allow developer to position [`AR.Drawables`](architectapi://reference/classes/Drawable.html) in 3D space using the Plugins API. The new [marker tracking example](positionable.html) provides a detailed demonstration of this feature.
- New InputFrameRenderSettings options for Plugins API
- A new include for the `architect.js` to prevent mixed content errors in https environments

#### Fixed
###### SDK
- Fixes issues with NAT64 networks
- Fixes an issue where [`AR.CloudTracker`](architectapi://reference/classes/CloudTracker.html) would not be able to send proper server requests
- Fixes an issue when enabling and disabling the camera via [`AR.hardware.camera.enabled`](architectapi://reference/classes/hardware.html#property_camera.enabled)
- Fixes an issue when resolving relative paths inside the JavaScript library
- Fixes an issue where the SDK could crash if a different Architect World is loaded and the previous one used cloud recognition
- Fixes an issue with snap-to-screen contents that get distorted when screen is rotated while the app is in background
- Fixes an issue with AR.Radar that get distorted when screen is rotated while the app is in background
- Fixes a rare crash in the 3D Tracking engine
- `isDeviceSupported` now correctly works for the iPod Touch 5th gen
- Fix for broken CMMotionManager implementation in iOS 10

#### Improved
- Improved memory handling of 3D models
- Video drawables report more errors 
- Improved and aligned behaviour of cache handling
- SampleApp now fully ATS compliant - only uses `https` links for content loading


## Wikitude SDK JavaScript API 5.2.0
Release Date: 08.07.2016

#### New
###### SDK
- InputPlugins allow developer to use the Wikitude SDK with an external camera feed

#### Fixed
###### SDK
- Fixen an issue where `AR.ImageDrawables` might not appear after loading an Architect World or resuming the SDK
- Fixes an issue where 3D models might not be rendered correctly after the SDK paused/resumed
- Fixes an issue where destroying the SDK while a large .wtc file is loading, crashed the SDK
- Fixes several issues that might lead to a crash if the SDK is paused/resumed
- Fixes several issues that might lead to a crash if the SDK is destroyed and immediately afterwards created again
- The device sensor calibration screen can now reliable be turned off. A new API can be used to react in code to uncalibrated device sensors
- Fixes an issue where green camera frames could be rendered under certain circumstances
- Fixes an issue where video drawables might only play there audio track
- Fixes an issue where taking a screenshot might not release all temporary allocated memory
- Fixes several issues where destroying the SDK might not release all of its allocated memory

###### 3D Encoder
- Fixes animations with negative start offsets
- Fixes animations containing several takes
- Fixes “texture not found” bug on Windows
- Adds a new warning in case of invalid polygon indices of materials
- Update to FBX SDK 2017, FBX version 7.5


## Wikitude SDK JavaScript API 5.1.4
Release Date: 14.03.2016

#### New
###### 3D Encoder
- Option to select the type of back-face culling that should be applied when rendering the 3D model

#### Fixed
###### SDK
- Memory leak when using continuous cloud recognition
- 3D models with 'Grouping on Takes' did not consider different animation offsets
- 3D models with non-power-of-two textures causing black textures on iOS devices

###### 3D Encoder
- Windows 3D Encoder always rendered empty scenes


## Wikitude SDK JavaScript API 5.1.3
Release Date: 03.03.2016

#### New
- New JS API to specify a `custom cloud recognition server url` through [`AR.context`](architectapi://reference/classes/context.html)

###### 3D Encoder
- different modes for grouping animations
- mesh deformer animations take into account geometric transforms mesh transformations
- support for shared joint nodes
- new wt3 file format; wt3 created with Encoder 1.3 cannot be used with SDK < 5.1.3 

#### Fixed
###### SDK
- `onError` trigger not called if local assets could not be loaded
- `AR.ModelAnimation` `onFinish` trigger not called
- Texture settings for 3D model rendering
- Mesh deformer animations take into account geometric transforms mesh transformations
- `CloudTracker` might not load on low end devices
- Camera and sensors could not be started or stopped from the JS API
- NSError pointer was always set to an actual error when starting the SDK although the SDK did start correctly

###### 3D Encoder
- Memory leak on screenshot creation    


## Wikitude SDK JavaScript API 5.1.2
Release Date: 11.02.2016

#### Fixed
- Crash on low end devices regarding threading
- Crash when using multiple video drawables 
- Radar always pointing west
- Linker error when using the SDK in a library/framework project
- Continuous cloud recognition could not be stopped
- Injecting an arbitrary location had no effect


## Wikitude SDK JavaScript API 5.1.1
Release Date: 12.01.2016

#### Fixed
- Crash on devices running iOS 7
- Missing textures on certain 3D models


## Wikitude SDK JavaScript API 5.1.0
Release Date: 01.12.2015

#### New
 - Option to specify if the system compass calibration screen should be shown or not
 - Support multiple regional co-located cloud recognition services
 - 3D model import: account for pivot node transformations

#### Fixed
 - Potential crash when multiple `WTArchitectView` instances are created
 - Black camera rendering when pausing/resuming the Wikitude iOS SDK
 - 3D model import: 
   - Animation grouping
   - Account for animation stack (numbering of animations if more than one animation tracks are on the FBX animation stack)
   - Accept the first texture of a multi-textured 3D model
   - Accept 3D models with more than one mesh skins per node


## Wikitude SDK JavaScript API 5.0.0
Release Date: 27.08.2015

#### New
 - Extended Tracking
 - Plugins API
 - Unity Plugin
 - Native API 
 
#### Fixed
 - Potential problem with 3D special effects causing crashes
 - Potential problem when calling `trackable.drawables.addCamDrawable()` while snapping is active
 - Wrong log messages for connection not found
 - Potential problem when clicking parts of a 3D model
 - Potential problem when 3D models are re-loaded fast
 - Potential memory increase with certain 3D models
 - Problem when at the same time addCamDrawable is called in the onExitFieldOfVision event
 - Potential problem with texture rendering when clicking a button

#### Improved
 - Newest version of 3D rendering engine


## Wikitude SDK JavaScript API 4.1.1
Release Date: 27.04.2015

#### Fixed
- Missing QT 5 .dll's for Windows 3D Encoder
- AR.Model `onError` handler now has more details about what failed
- Loading of [`ClientTracker`](architectapi://reference/classes/ClientTracker.html) works as expected when no `onLoaded` trigger is set
- An issue with inverted axis when using image recognition in combination with the front camera
- Documentation clarifications and fixes 
- Updated Terms of Service

## Wikitude SDK JavaScript API 4.1.0
Release Date: 03.03.15

#### New
- New JS API `AR.CloudTracker` for cloud recognition support
- Access to the device front cam through a JavaScript and Objective-C API
- Information about the distance to a image target
- Click's on 3D models now return the name of the affected mesh part
- New required iOS SDK framework: `SystemConfiguration.framework`
- API changes
    - new class `WTStartupConfiguration`
    - new bit mask `WTFeatures`
    - updated class `WTArchitectView`
        - new method to check if the device is supported
        - new method to start the SDK rendering
    - deprecated enum `WTAugemntedRealityMode`
    - deprecated methods that were using the `WTAugmentedRealityMode` enum
- Quick Look Plugin for Mac OS X which allows introspection of `.wtc` files

#### Fixed
- Potential Memory issue when changing properties of 3d model
- Potential problems when loading large `.wtc` files
- `onSnappedToScreen` function is not called when using the `enabledOnExitFieldOfVision` property
- Potential problems with animated 3D Models not clickable

#### Improved
- Performance of Image Recognition initial recognition phase
- Tracking Performance optimized and streamlined
- JS <=> ObjC bridge performance
- Example app with new examples for any of the new features


## Wikitude SDK JavaScript API 4.0.2
Release Date: 09.10.14

#### New
- Support/Improvements for iOS 8
- Example application
- API changes 
    - new class WTNavigation
    - updated class WTArchitectView
    - updated protocol WTArchitectViewDelegate
    - updated enum WTAugmentedRealityMode
- Load ARchitect Worlds with an augmented reality mode ( -loadArchitectWorldFromURL:withAugmentedRealityMode: )
- Umbrella header `WikitudeSDK.h` ( #import <WikitudeSDK/WikitudeSDK.h> )

#### Improved
- Image target recognition
- Java Script bridge is now more robust at startup
- Reloading ARchitect Worlds with the same WTArchitectView instance
- Error messages
    - pls. implement the -architectView:didFailLoadArchitectWorldNavigation:withError delegate method
    - check the console output
- Namespace handling in C++

#### Fixed
- Warning logs that JPEG or GIF is not a supported image format (introduced in 4.0.2 from 11.09.14)
- Landscape initialized WTArchitectView wasn't able to detect any image target
- Fixes an issue with flickering augmentations for certain image targets
- Fixes an issue where the 'onSnappedToScreen' function was not called when using the 'enabledOnExitFieldOfVision' property

## Wikitude SDK JavaScript API 4.0.0 
Release Date: 29.07.14

#### New
- "Snap-to-screen" feature (see samples [3D Model](3dmodels.html#snapToScreen) and [Video](video.html#snappedvideo) for implementation)
- Wildcard support for the [`targetName`](architectapi://reference/classes/Trackable2DObject.html#property_targetName) property of [`Trackable2DObject`](architectapi://reference/classes/Trackable2DObject.html)
- New tracking engine with increased performance 
- Control flash light from augmented reality scene ([`AR.context.hardware.flashlight`](architectapi://reference/classes/context.html#property_hardware.flashlight)) 
- SDK version number is now accessible from JS ([`AR.context.versionNumber`](architectapi://reference/classes/context.html#property_versionNumber))
- Required license key

#### Fixed
- A potential issue that caused rendering artifacts when objects were created outside of the current culling distance
- Pause and resume animation of 3D models correctly after app is put in background
- A potential issue with 3D models that were not deleted correctly from a temporary directory
- A potential issue with 3D models that were not destroyed correctly when using the JS `destroy()` API

#### Improved
- Camera rendering is now faster
- Samples to reflect Snap-to-screen feature and wildcard support
- Comments in sample apps source code


## Wikitude SDK JavaScript API 3.3.2 
Release Date: 31.07.14

#### Fixed
- Fixes a potential issue with 3D models that were not deleted correctly from a temporary directory

## Wikitude SDK JavaScript API 3.3.1
Release Date 21.04.2014

#### Fixed
- Screen capturing on iPhones was not working properly
- Notifications regarding MPMoviePlayerViewController states were not handled correctly and could lead to a crash
- Some PNG images couldn't be loaded

## Wikitude SDK JavaScript API 3.3.0 
Release Date 01.04.2014

#### New
- Multiple AR views supported
- URL scheme support for `tel:`, `sms:` and `mailto:`
- Scaling mode: Global Scene (See [JavaScript API Reference](architectapi://reference/classes/context.html) for more details)
- Full Interface Builder support for WTArchitectView
- Support for 64-bit `arm64` architecture 
- IR-only mode for AR experiences

#### Fixed
- Flickering after resume from background 
- Possible mix-up of 3D textures with the same name in different 3D models

#### Improved
- Text Label Rendering - trailing whitespace is now constant
- Framerate on iPhone 4 is now constant
- Open In Browser UI 
- libpng uses own symbols to avoid symbol conflicts

#### Removed
- Support for iOS 5


## Wikitude SDK JavaScript API 3.2.1 
Release Date 04.12.2013

#### Fixed 
- Compilation error preventing gif files to be shown in AR scene
- Animation loops of 3D models
- onError trigger not called for images in not supported format
- Issue where the SDK could crash while the app goes into background
- Issue that broke loading of local resources if the relative path or the bundle name contains a whitespace character
- Rare case where objects appear frozen on the screen
- Issue that the SDK consumes more memory the more often it is started or stopped

#### Improved
- Warning and error log output for Xcode console


## Wikitude SDK JavaScript API 3.2.0
Release Date 10.10.2013

#### New 
- VideoDrawables to display videos on top of image targets or as part of `GeoObjects`
- Taking screenshot of AR scene
- Examples for VideoDrawables
- Accuracy hint for location retrieval can be configured
- Example App and SDK is fully iOS 7 compliant


#### Fixed 
- ADE.js interfered with architect.js under certain circumstances when loaded from bundle/assets
- AR.context.openInBrowser in some circumstances failed to open the webpage
- Rendering order between HTMLDrawables was not correct


#### Improved
- Resource loading and caching of images, 3D models and tracker files
- Loading time of image recognition tracker
- Reworked radar positioning. Radar position is now defined by an DOM element on the HUD (see examples and updated JS API specification)
- Browse POI samples

## Wikitude SDK JavaScript API 3.1.0 
Release Date 27.08.2013

#### Fixed 
- Fixed problem with 16 bit PNG images not being drawn.
- AnimatedImageDrawable's frame rate was ignored after resume.
- Executing onDocumentLocationChanged trigger for HTML Drawable in ADE was broken
- Potential linker error while linking Xamarin.iOS projects

#### Improved
- HTML Drawables work correctly with dynamic content
- Image detection two times faster
- Better support for target images with low contrast
- More reliable tracking, especially for difficult target images
- Optimized texture memory usage for non square images

## Wikitude SDK JavaScript API 3.0.0 
Release Date 18.06.2013

#### New
- Integrated image recognition and tracking engine
- Support armv7s architecture
- Examples application
- Support for 3D model animations
- Support for transparent materials, textures and colors on 3D models
- API method for setting distance based scaling parameters. See reference on AR.context.scene.

#### Fixed
- Under certain circumstances the light of a 3D model was ignored
- isLoaded() methods of ImageResource, ClientTracker,... on iOS returned integer instead of boolean.
- NSURL accepted for loading an architect world. Adds support for white spaces in bundle name.

#### Improved
- Image recognition supports up to 1000 targets
- Rewritten, extended and improved SDK documentation
- Minor fixes

#### Removed
- Support for Vuforia SDK


## Wikitude SDK JavaScript API 2.0.1 
Release Date 15.05.2013

#### Fixed
- Reference to UDID in Vuforia SDK

## Wikitude SDK JavaScript API 2.0.0 
Release Date 26.02.2013

#### New
- Support for 3D models via new ARchitect class Model 
- iPod touch support for pure image recognition use-case. Use isDeviceSupportedForARMode:WTARMode_IR;

#### Improved
- Stability improvements when using image recognition
- Minor fixes and performance improvements

## Wikitude SDK JavaScript API 1.2.0 
Release Date 18.12.2012

#### New
- Improved bridge performance (SteelBridge and Weasel)
- onFinish trigger for AnimatedImageDrawables
- ImageResource onLoad() reports width and height of loaded image
- PropertyAnimation can be paused and resumed
- Customize clicking behavior (click, touch down, touch up)
- Set culling distance from JavaScript
- Support for Vuforia SDK v2.0

#### Improved
- Architect Desktop Engine (ADE) now overlays world

#### Removed
-  SBJSON library, resolves duplicated symbols error if SBJSON library was used by application as well

#### Note
-  New linker flag: -ObjC
 
## Wikitude SDK JavaScript API 1.1.1 
Release Date 26.09.2012
#### New
- iOS 6 support

#### Fixed
- Possible crash when using openInBrowser or startVideoPlayer while IR is active
- Possible crash when calling start / stop while IR is active

#### Improved
- Handling of unavailable gyroscope on iOS
- Minor performance increase for rendering HTML drawables.
- Handling of images with semi transparency

## Wikitude SDK JavaScript API 1.1.0 
Release Date 16.08.2012
#### New
 - HTML Drawables 
 - Relative locations 
 - Customizable AR radar
 - Sprite Animations
 - 3D Transformation
 - Animation Groups
 - Extension for Qualcomm Vuforia SDK for Image Recognition
 - Possibility to turn off camera and sensors
 - Possibility to add a single drawable to multiple GeoObjects
 
#### Fixed
 - Autorotation support 
 - ADE shown in certain conditions on device  
  
#### Improved
 - New tutorials and snippets
 - Library Reference examples and texts
 - New simple IR example
 - Streamlined trigger properties
 - Rendering performance in general
 - Performance of AR.logger output on device
 
## Wikitude SDK JavaScript API 1.0.5
#### New
- setCullingDistance to ArchitectView (SDK)
- possibility for better error handling when loading an ARchitect World (SDK)

#### Improved
- SimpleARBrowser example

#### Fixed
 - Location service not turned off in certain conditions
 - Camera is displayed bigger than it should be in certain conditions 
 - WTArchtiectView does not properly work when created for the 2nd time

#### Note
- If you are targeting iOS version 4.x you have to additionally include the following Other Linker Flags: -fobjc-arc  
- Including a viewport meta-tag in your ARchitect World is recommended if you target different screen resolutions (see ARchitectTools/Hello World/Hello World.html for more details)

## Wikitude SDK JavaScript API 1.0.4
- Licensable SDK
  
## Wikitude SDK JavaScript API 1.0.3
- Initial Public SDK Release
