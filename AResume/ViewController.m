//
//  ViewController.m
//  AResume
//
//  Created by 吴肇锋 on 10/16/16.
//  Copyright © 2016 AResume. All rights reserved.
//

#import "ViewController.h"

#import <WikitudeNativeSDK/WikitudeNativeSDK.h>

#import "WikitudeLicense.h"
#import "StrokedRectangle.h"
#import "ExternalRenderer.h"

@interface ViewController () <WTWikitudeNativeSDKDelegate, WTClientTrackerDelegate>

@property (nonatomic, strong) WTWikitudeNativeSDK                           *wikitudeSDK;
@property (nonatomic, strong) WTClientTracker                               *clientTracker;

@property (nonatomic, strong) EAGLContext                                   *sharedWikitudeEAGLCameraContext;

@property (nonatomic, copy) WTWikitudeUpdateHandler                         wikitudeUpdateHandler;
@property (nonatomic, copy) WTWikitudeDrawHandler                           wikitudeDrawHandler;

@property (nonatomic, assign) BOOL                                          isTracking;

@property (nonatomic, strong) ExternalRenderer                              *renderer;
@property (nonatomic, strong) StrokedRectangle                              *renderableRectangle;

@end

@implementation ViewController

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.renderer = [[ExternalRenderer alloc] init];
    self.renderableRectangle = [[StrokedRectangle alloc] init];
    
    self.wikitudeSDK = [[WTWikitudeNativeSDK alloc] initWithRenderingMode:WTRenderingMode_External delegate:self];
    [self.wikitudeSDK setLicenseKey:kWTLicenseKey];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.renderer setupRenderingWithLayer:[self.eaglView eaglLayer]];
    [self.renderer startRenderLoopWithRenderBlock:[self renderBlock]];
    
    [self.wikitudeSDK start:nil completion:^(BOOL isRunning, NSError * __nonnull error) {
        if ( !isRunning ) {
            NSLog(@"Wikitude SDK is not running. Reason: %@", [error localizedDescription]);
        }
        else
        {
            NSURL *clientTrackerURL = [[NSBundle mainBundle] URLForResource:@"magazine" withExtension:@"wtc" subdirectory:@"Assets"];
            self.clientTracker = [self.wikitudeSDK.trackerManager create2DClientTrackerFromURL:clientTrackerURL extendedTargets:nil andDelegate:self];
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.wikitudeSDK stop];
    
    [self.renderer stopRenderLoop];
    [self.renderer teardownRendering];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self.wikitudeSDK shouldTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ExternalRenderer render loop
- (ExternalRenderBlock)renderBlock
{
    return ^ (CADisplayLink *displayLink) {
        if ( self.wikitudeUpdateHandler
            &&
            self.wikitudeDrawHandler )
        {
            self.wikitudeUpdateHandler();
            self.wikitudeDrawHandler();
        }
        
        [self.renderer bindBuffer];
        
        if ( _isTracking )
        {
            [self.renderableRectangle drawInContext:[self.renderer internalContext]];
        }
    };
}

#pragma mark - Notifications
- (void)didReceiveApplicationWillResignActiveNotification:(NSNotification *)notification
{
    [self.wikitudeSDK stop];
    
    [self.renderer stopRenderLoop];
}

- (void)didReceiveApplicationDidBecomeActiveNotification:(NSNotification *)notification
{
    [self.renderer startRenderLoopWithRenderBlock:[self renderBlock]];
    
    [self.wikitudeSDK start:nil completion:^(BOOL isRunning, NSError * __nonnull error) {
        if ( !isRunning ) {
            NSLog(@"Wikitude SDK is not running. Reason: %@", [error localizedDescription]);
        }
    }];
}

#pragma mark - Delegation
#pragma mark WTWikitudeNativeSDKDelegte
- (void)wikitudeNativeSDK:(WTWikitudeNativeSDK * __nonnull)wikitudeNativeSDK didCreatedExternalUpdateHandler:(WTWikitudeUpdateHandler __nonnull)updateHandler
{
    self.wikitudeUpdateHandler = updateHandler;
}

- (void)wikitudeNativeSDK:(WTWikitudeNativeSDK * __nonnull)wikitudeNativeSDK didCreatedExternalDrawHandler:(WTWikitudeDrawHandler __nonnull)drawHandler
{
    self.wikitudeDrawHandler = drawHandler;
}

- (EAGLContext *)eaglContextForVideoCameraInWikitudeNativeSDK:(WTWikitudeNativeSDK * __nonnull)wikitudeNativeSDK
{
    if (!_sharedWikitudeEAGLCameraContext )
    {
        EAGLContext *rendererContext = [self.renderer internalContext];
        self.sharedWikitudeEAGLCameraContext = [[EAGLContext alloc] initWithAPI:[rendererContext API] sharegroup:[rendererContext sharegroup]];
    }
    return self.sharedWikitudeEAGLCameraContext;
}

- (CGRect)eaglViewSizeForExternalRenderingInWikitudeNativeSDK:(WTWikitudeNativeSDK * __nonnull)wikitudeNativeSDK
{
    return self.eaglView.bounds;
}

- (void)wikitudeNativeSDK:(WTWikitudeNativeSDK * __nonnull)wikitudeNativeSDK didEncounterInternalError:(NSError * __nonnull)error
{
    NSLog(@"Internal Wikitude SDK error encounterd. %@", [error localizedDescription]);
}

#pragma mark WTClientTrackerDelegate

- (void)baseTracker:(nonnull WTBaseTracker *)baseTracker didRecognizedTarget:(nonnull WTImageTarget *)recognizedTarget
{
    NSLog(@"recognized target '%@'", [recognizedTarget name]);
    _isTracking = YES;
}

- (void)baseTracker:(nonnull WTBaseTracker *)baseTracker didTrackTarget:(nonnull WTImageTarget *)trackedTarget
{
    [self.renderableRectangle setProjectionMatrix:trackedTarget.projection];
    [self.renderableRectangle setModelViewMatrix:trackedTarget.modelView];
}

- (void)baseTracker:(nonnull WTBaseTracker *)baseTracker didLostTarget:(nonnull WTImageTarget *)lostTarget
{
    NSLog(@"lost target '%@'", [lostTarget name]);
    _isTracking = NO;
}


- (void)clientTracker:(nonnull WTClientTracker *)clientTracker didFinishedLoadingTargetCollectionFromURL:(nonnull NSURL *)URL
{
    NSLog(@"Client tracker loaded");
}

- (void)clientTracker:(nonnull WTClientTracker *)clientTracker didFailToLoadTargetCollectionFromURL:(nonnull NSURL *)URL withError:(nonnull NSError *)error
{
    NSLog(@"Unable to load client tracker from URL '%@'. Reason: %@", [URL absoluteString], [error localizedDescription]);
}



@end
