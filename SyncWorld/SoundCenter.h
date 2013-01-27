//
//  SoundCenter.h
//  SyncWorld
//
//  Created by Joel Davis on 1/26/13.
//  Copyright (c) 2013 Tapnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "SampleBuffer.h"

@interface SoundCenter : NSObject


@property (nonatomic, assign) GLKVector2 center;
@property (nonatomic, assign) float radius;
@property (nonatomic, assign) int iconIndex; 

- (id)initWithSample: (SampleBuffer *)buffer;

- (void)drawIcon;
- (void)drawWaveform;

@end
