//
//  SampleBuffer.h
//  SyncWorld
//
//  Created by Joel Davis on 1/26/13.
//  Copyright (c) 2013 Tapnik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SampleBuffer : NSObject

@property (nonatomic, assign) UInt32 numFrames;
@property (nonatomic, readonly) float *data;

- (id) initFromFile: (NSString*)filename;


@end
