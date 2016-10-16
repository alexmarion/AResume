//
//  WTYUVInputCamera.h
//  DevApplication
//
//  Created by Andreas Schacherbauer on 14/03/16.
//  Copyright © 2016 Wikitude. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <memory>

#include "YUVFrameInputPlugin.hpp"


@interface WTYUVInputCamera : NSObject

- (instancetype)init;

- (std::shared_ptr<YUVFrameInputPlugin>&)cameraInputPlugin;

@end
