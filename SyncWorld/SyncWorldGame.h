//
//  SyncWorldGame.h
//  SyncWorld
//
//  Created by Joel Davis on 1/26/13.
//  Copyright (c) 2013 Tapnik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncWorldGame : NSObject

- (void) startAudio;

+ (SyncWorldGame*) sharedInstance;

@end
