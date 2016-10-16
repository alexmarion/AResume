//
//  WikitudeSDKOptionsDataSource.m
//  DevApplication_ExternalRendering
//
//  Created by Andreas Schacherbauer on 22/06/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#import "WTCameraControlsModel.h"

#import <WikitudeNativeSDK/WikitudeNativeSDK.h>


@interface WTCameraControlsModel ()
@property (nonatomic, strong) NSArray                   *optionOptions;

@property (nonatomic, strong) NSArray                   *cameraPositionOptions;
@property (nonatomic, strong) NSArray                   *cameraFocusModes;
@property (nonatomic, strong) NSArray                   *continuousAutoFocusModes;
@end

@implementation WTCameraControlsModel

+ (AVCaptureDevicePosition)devicePositionForRow:(NSInteger)row
{
    AVCaptureDevicePosition devicePosition = (AVCaptureDevicePosition)row;
    return devicePosition;
}

+ (AVCaptureFocusMode)focusModeForRow:(NSInteger)row
{
    AVCaptureFocusMode focusMode = (AVCaptureFocusMode)row;
    return focusMode;
}

+ (AVCaptureAutoFocusRangeRestriction)autoFocusRangeRestrictionForRow:(NSInteger)row
{
    AVCaptureAutoFocusRangeRestriction autoFocusRangeRestriction = (AVCaptureAutoFocusRangeRestriction)row;
    return autoFocusRangeRestriction;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _optionOptions = @[@"Position", @"Focus Mode", @"Auto Focus Restriction"];
        _cameraPositionOptions = @[@"Unspecified", @"Back", @"Front"];
        _cameraFocusModes = @[@"Locked", @"Once", @"Continuous"];
        _continuousAutoFocusModes = @[@"None", @"Near", @"Far"];
    }

    return self;
}

#pragma mark - Public Methods
- (void)updatePickerView:(UIPickerView *)pickerView
{
    NSInteger currentlySelectedMainRow = [pickerView selectedRowInComponent:0];
    BOOL shouldAnimateChanges = YES;
    
    /* Check if capture device positions needs an update */
    if ( 0 == currentlySelectedMainRow ) {
        AVCaptureDevicePosition currentlyActiveCaptureDevicePosition = [self.delegate currentlyActiveCameraPositionForCameraControlsModel:self];
        NSInteger activeCaptureDevicePositionRow = (NSInteger)currentlyActiveCaptureDevicePosition;
        
        [pickerView selectRow:activeCaptureDevicePositionRow inComponent:1 animated:shouldAnimateChanges];
    }
    /* or focus mode */
    else if ( 1 == currentlySelectedMainRow )
    {
        AVCaptureFocusMode currentlyActiveCaptureFocusMode = [self.delegate currentlyActiveFocusModeForCameraControlsModel:self];
        NSInteger activeCaptureDeviceFocusModeRow = (NSInteger)currentlyActiveCaptureFocusMode;

        [pickerView selectRow:activeCaptureDeviceFocusModeRow inComponent:1 animated:shouldAnimateChanges];
    }
    /* or auto focus range restriction */
    else if ( 2 == currentlySelectedMainRow )
    {
        AVCaptureAutoFocusRangeRestriction currentlyActiveAutoFocusRangeRestriction = [self.delegate currentlyActiveAutoFocusRangeRestrictionForCameraControlsModel:self];
        NSInteger activeAutoFocusRangeRestrictionRow = (NSInteger)currentlyActiveAutoFocusRangeRestriction;

        [pickerView selectRow:activeAutoFocusRangeRestrictionRow inComponent:1 animated:shouldAnimateChanges];
    }
}

#pragma mark - Delegation
#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numberOfRowsInComponent = 0;

    if ( 0 == component )
    {
        numberOfRowsInComponent = [_optionOptions count];
    }
    else if ( 1 == component )
    {
        if ( 0 == [pickerView selectedRowInComponent:0] ) {
            numberOfRowsInComponent = [_cameraPositionOptions count];
        }
        else if ( 1 == [pickerView selectedRowInComponent:0] )
        {
            numberOfRowsInComponent = [_cameraFocusModes count];
        }
        else if ( 2 == [pickerView selectedRowInComponent:0] )
        {
            numberOfRowsInComponent = [_continuousAutoFocusModes count];
        }
    }

    return numberOfRowsInComponent;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *titleForRow = @"";

    if ( 0 == component )
    {
        titleForRow = [_optionOptions objectAtIndex:row];
    }
    else if ( 1 == component )
    {
        if ( 0 == [pickerView selectedRowInComponent:0] ) {
            titleForRow = [_cameraPositionOptions objectAtIndex:row];
        }
        else if ( 1 == [pickerView selectedRowInComponent:0] )
        {
            titleForRow = [_cameraFocusModes objectAtIndex:row];
        }
        else if ( 2 == [pickerView selectedRowInComponent:0] )
        {
            titleForRow = [_continuousAutoFocusModes objectAtIndex:row];
        }
    }

    return titleForRow;
}

#pragma mark UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ( 0 == component ) {
        [pickerView reloadComponent:component +1];
        [self updatePickerView:pickerView];
    }
    if ( 1 == component ) {
        if ( 0 == [pickerView selectedRowInComponent:0] )
        {
            [self.delegate cameraControlsModel:self didSelectCameraPosition:[WTCameraControlsModel devicePositionForRow:row]];
        }
        else if ( 1 == [pickerView selectedRowInComponent:0] )
        {
            [self.delegate cameraControlsModel:self didSelectCameraFocusMode:[WTCameraControlsModel focusModeForRow:row]];
        }
        else if ( 2 == [pickerView selectedRowInComponent:0] )
        {
            [self.delegate cameraControlsModel:self didSelectContinuousAutoFocusMode:[WTCameraControlsModel autoFocusRangeRestrictionForRow:row]];
        }
    }
}


@end
