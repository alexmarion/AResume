//
//  WTAugmentedRealityViewController.m
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 23/09/14.
//  Copyright (c) 2014 Wikitude. All rights reserved.
//

#import "WTAugmentedRealityViewController.h"

#import "NSURL+ParameterQuery.h"

#import "WTAugmentedRealityExperience.h"

#import "WTAugmentedRealityViewController+ExampleCategoryManagement.h"
#import "WTAugmentedRealityViewController+PresentingPoiDetails.h"
#import "WTAugmentedRealityViewController+ScreenshotSharing.h"



/* Wikitude SDK license key (only valid for this application's bundle identifier) */
#define kWT_LICENSE_KEY @"WXoYaTXM/SxD7qGJgNP6/Bn6YbyWXbOynJhkeKixypgiXYZ8YNnV44nBUM8xfaniKd+Kys9GoXyh4sRXTnJoMVjmAiIdhPf1F2E4AVZxag1DmYDQgTANuTQtL8UuK2cWZ1Ku9UDy3r8c6S6oQewOEHhndHLyBKTvSa7meDk47uFTYWx0ZWRfX1ZivtPEgZgFppYXb67MR/Lnb2IpFqo7MFF0l74lTv2V51BhsGfC/abBMsQ7uoI0V95YJa8UaHJTUZAYpfGkCRyK3eRh/oSZ9eUB0YL7esVUAi6dqerVWMPqFA2fl9qN7mJ2aT1Us/3upF4yyAGCm7P4jNr2c/vYxH5yIDAOoRG9IuHyVkBe8VS0Ov8s+vs4pSv+nl0CMi1TALlQiX5KGPioRBZ0B8y1S8IzJD6BAzenIC2tknmcf2CCG/xOq+8hsNwkVLoMetmRd0Rdeg1P5xvmNHZXI98F7yiPQEVCgvkt+u2B4z+9ypmbyLiBhxvUrfrz6hoGG7CTaQVF0Qqhj/yA+VXBiESJ18OM5rr/3v3g9HT6sgoujbfLRkLayPehWnVKGuD5UjM7Lk8d3qZ/yWjpcOJXgtIO5PKL73MeXqTNUbY/wqur7scac5XiTw31M5fUM0NQjwpKXaN0e+NwiGrGtigzNCev5Q=="


@interface WTAugmentedRealityViewController ()

@property (nonatomic, assign) BOOL                                          showsBackButtonOnlyInNavigationItem;
@property (nonatomic, weak) WTAugmentedRealityExperience                    *augmentedRealityExperience;
@property (nonatomic, copy) WTNavigation                                    *loadedArchitectWorldNavigation;
@property (nonatomic, weak) WTNavigation                                    *loadingArchitectWorldNavigation;

@end


@implementation WTAugmentedRealityViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Architect view specific initialization code 
     * - a license key is set to enable all SDK features
     * - the architect view delegate is set so that the application can react on SDK specific events
     */
    [self.architectView setLicenseKey:kWT_LICENSE_KEY];
    self.architectView.delegate = self;
    
    
    /* The architect view needs to be paused/resumed when the application is not active. We use UIApplication specific notifications to pause/resume architet view rendering depending on the application state */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* Set’s a nicely formatted navigation item title based on from where this view controller was pushed onto the navigation stack */
    NSString *navigationItemTitle = self.augmentedRealityExperience.title;
    if ( UIUserInterfaceIdiomPad == [[UIDevice currentDevice] userInterfaceIdiom] )
    {
        NSString *urlString = [self.augmentedRealityExperience.URL isFileURL] ? @"" : [NSString stringWithFormat:@" - %@", [self.augmentedRealityExperience.URL absoluteString]];
        navigationItemTitle = [NSString stringWithFormat:@"%@%@", self.augmentedRealityExperience.title, urlString];
    }
    self.navigationItem.title = navigationItemTitle;
    
    if ( self.showsBackButtonOnlyInNavigationItem )
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    /* Depending on the currently load architect world a new world will be loaded */
    [self checkExperienceLoadingStatus];
    /* And the Wikitude SDK rendering is resumed if it’s currently paused */
    [self startArchitectViewRendering];
    /* Just to make sure that the Wikitude SDK is rendering in the correct interface orientation just in case the orientation changed while this view was not visible */
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self.architectView setShouldRotate:YES toInterfaceOrientation:orientation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /* Pause architect view rendering when this view is not visible anymore */
    [self stopArchitectViewRendering];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Public Methods

- (void)loadAugmentedRealityExperience:(WTAugmentedRealityExperience *)experience showOnlyBackButton:(BOOL)showBackButtonOnlyInNavigationItem
{
    /* This method could be called at any time so we keep a referenz to the experience object and load it’s architect world once it’s guaranteed that the architect view is loaded from the storyboard */
    self.augmentedRealityExperience = experience;
    
    
    /* Depending from where this view controller was pushed we want to display the back button only or an additional done button. */
    self.showsBackButtonOnlyInNavigationItem = showBackButtonOnlyInNavigationItem;
    
    
    /* A few architect world examples require additional iOS specific implementation details. These details are given in three class extensions.
     * Some example specific code is done once the example should be loaded.
     */
    [self loadExampleSpecificCategoryForAugmentedRealityExperience:experience];
}


#pragma mark - Layout / Rotation

/* Wikitude SDK Rotation handling
 *
 * viewWillTransitionToSize -> iOS 8 and newer
 * willRotateToInterfaceOrientation -> iOS 7
 *
 * Overriding both methods seems to work for all the currently supported iOS Versions
 * (7, 8, 9). The run-time version check is included nonetheless. Better safe than sorry.
*/

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
   if (coordinator)
   {
       [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
        {
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
            [self.architectView setShouldRotate:YES toInterfaceOrientation:orientation];

        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
        {

        }];
   }
   else
   {
       UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
       [self.architectView setShouldRotate:YES toInterfaceOrientation:orientation];
   }

   [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //if iOS 8.0 or greater according to http://stackoverflow.com/questions/3339722/how-to-check-ios-version
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        return;
    }
    [self.architectView setShouldRotate:YES toInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - Delegation
#pragma mark WTArchitectView

/* This architect view delegate method is used to keep the currently loaded architect world url. Every time this view becomes visible again, the controller checks if the current url is not equal to the new one and then loads the architect world */
- (void)architectView:(WTArchitectView *)architectView didFinishLoadArchitectWorldNavigation:(WTNavigation *)navigation
{
    if ( [self.loadingArchitectWorldNavigation isEqual:navigation] )
    {
        self.loadedArchitectWorldNavigation = navigation;
    }
}

- (void)architectView:(WTArchitectView *)architectView didFailToLoadArchitectWorldNavigation:(WTNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"architect view '%@' \ndid fail to load navigation '%@' \nwith error '%@'", architectView, navigation, error);
}

/* As mentioned before, some architect examples require iOS specific implementation details.
 * Here is the decision made which iOS specific details should be executed
 */
- (void)architectView:(WTArchitectView *)architectView invokedURL:(NSURL *)URL
{
    NSDictionary *parameters = [URL URLParameter];
    if ( parameters )
    {
        if ( [[URL absoluteString] hasPrefix:@"architectsdk://button"] )
        {
            NSString *action = [parameters objectForKey:@"action"];
            if ( [action isEqualToString:@"captureScreen"] )
            {
                [self captureScreen];
            }
        }
        else if ( [[URL absoluteString] hasPrefix:@"architectsdk://markerselected"])
        {
            [self presentPoiDetails:parameters];
        }
    }
}

/* Use this method to implement/show your own custom device sensor calibration mechanism.
 *  You can also use the system calibration screen, but pls. read the WTStartupConfiguration documentation for more details.
 */
- (void)architectViewNeedsDeviceSensorCalibration:(WTArchitectView *)architectView
{
    NSLog(@"Device sensor calibration needed. Rotate the device 360 degree around it's Y-Axis");
}

/* When this method is called, the device sensors are calibrated enough to deliver accurate values again.
 * In case a custom calibration screen was shown, it can now be dismissed.
 */
- (void)architectViewFinishedDeviceSensorsCalibration:(WTArchitectView *)architectView
{
    NSLog(@"Device sensors calibrated");
}


#pragma mark - Notifications
/* UIApplication specific notifications are used to pause/resume the architect view rendering */
- (void)didReceiveApplicationWillResignActiveNotification:(NSNotification *)notification
{
    [self stopArchitectViewRendering];
}

- (void)didReceiveApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    if ( self.loadingArchitectWorldNavigation.wasInterrupted )
    {
        [self.architectView reloadArchitectWorld];
    }
    [self startArchitectViewRendering];
}


#pragma mark - Private Methods

/* The method that is invoked everytime the view becomes visible again and then decides if a new architect world needs to be loaded or not */
- (void)checkExperienceLoadingStatus
{
    if ( ![self.loadedArchitectWorldNavigation.originalURL isEqual:self.augmentedRealityExperience.URL] )
    {
        self.loadingArchitectWorldNavigation = [self.architectView loadArchitectWorldFromURL:self.augmentedRealityExperience.URL withRequiredFeatures:self.augmentedRealityExperience.requiredFeatures];
    }
}

/* The next two methods actually start/stop architect view rendering */
- (void)startArchitectViewRendering
{
    if ( ![self.architectView isRunning] )
    {
        [self startExampleSpecificCategoryForAugmentedRealityExperience:self.augmentedRealityExperience];
        
        [self.architectView start:^(WTStartupConfiguration *configuration)
        {
            NSString *captureDevicePositionString = [self.augmentedRealityExperience.startupParameters objectForKey:kWTAugmentedRealityExperienceStartupParameterKey_CaptureDevicePosition];
            configuration.captureDevicePosition = [captureDevicePositionString isEqualToString:kWTAugmentedRealityExperienceStartupParameterKey_CaptureDevicePosition_Back] ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
        }
        completion:^(BOOL isRunning, NSError *error) {
        }];
    }
}

- (void)stopArchitectViewRendering
{
    if ( [self.architectView isRunning] )
    {
        [self.architectView stop];
        [self stopExampleSpecificCategoryForAugmentedRealityExperience:self.augmentedRealityExperience];
    }
}

@end
