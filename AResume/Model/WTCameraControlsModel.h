//
//  WikitudeSDKOptionsDataSource.h
//  DevApplication_ExternalRendering
//
//  Created by Andreas Schacherbauer on 22/06/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>


@class WTStartupConfiguration;
@class WTCameraControlsModel;

@protocol WTCameraControlsModelDelegate <NSObject>
@required
- (void)cameraControlsModel:(WTCameraControlsModel *)cameraControlsModel didSelectCameraPosition:(AVCaptureDevicePosition)activeCameraPosition;
- (void)cameraControlsModel:(WTCameraControlsModel *)cameraControlsModel didSelectCameraFocusMode:(AVCaptureFocusMode)focusMode;
- (void)cameraControlsModel:(WTCameraControlsModel *)cameraControlsModel didSelectContinuousAutoFocusMode:(AVCaptureAutoFocusRangeRestriction)rangeRestriction;

- (AVCaptureDevicePosition)currentlyActiveCameraPositionForCameraControlsModel:(WTCameraControlsModel *)cameraControlsModel;
- (AVCaptureFocusMode)currentlyActiveFocusModeForCameraControlsModel:(WTCameraControlsModel *)cameraControlsModel;
- (AVCaptureAutoFocusRangeRestriction)currentlyActiveAutoFocusRangeRestrictionForCameraControlsModel:(WTCameraControlsModel *)cameraControlsModel;
@end

@interface WTCameraControlsModel : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id<WTCameraControlsModelDelegate>                    delegate;

- (void)updatePickerView:(UIPickerView *)pickerView;

@end
