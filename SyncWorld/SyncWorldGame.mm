//
//  SyncWorldGame.m
//  SyncWorld
//
//  Created by Joel Davis on 1/26/13.
//  Copyright (c) 2013 Tapnik. All rights reserved.
//
#import "Novocaine.h"
#import "RingBuffer.h"
#import "SyncWorldGame.h"
#import "SampleBuffer.h"

@interface SyncWorldGame ()
{
    RingBuffer *_ringBuffer;
    Novocaine *_audioManager;
    //    AudioFileReader *fileReader;

    SampleBuffer *_testSample;
}
@end

@implementation SyncWorldGame

+ (SyncWorldGame*) sharedInstance
{
    static dispatch_once_t onceToken;
    static SyncWorldGame *game;
    
    dispatch_once(&onceToken, ^{
        game = [[SyncWorldGame alloc] init];
    });
    
    return game;
}

- (void) startAudio
{
    _ringBuffer = new RingBuffer(32768, 2);
    _audioManager = [Novocaine audioManager];
    
    // Load our samples
//    NSString *samplePath = [[NSBundle mainBundle] pathForResource:@"GGJ13_Theme" ofType:@"wav"];
//    NSString *samplePath = [[NSBundle mainBundle] pathForResource:@"drums_ad3_007_120bpm" ofType:@"wav"];
    NSString *samplePath = [[NSBundle mainBundle] pathForResource:@"piano_notes" ofType:@"wav"];
    NSLog( @"Sample path is %@", samplePath );
    _testSample = [[SampleBuffer alloc] initFromFile:samplePath];
    
    // TEST SAMPLE PLAYBACK
    __block UInt32 fndx = 0;
    [_audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
     {
         for (int i=0; i < numFrames; i++)
         {
//             int fndx = i % _testSample.numFrames;
             fndx++;
             if (fndx >= _testSample.numFrames) fndx = 0;
             for (int chan=0; chan < numChannels; ++chan)
             {
                 data[i*numChannels+chan] = _testSample.data[fndx*numChannels+chan];
             }
         }
     }];
    
    // SIGNAL GENERATOR!
//    __block float frequency = 200.0;
//    __block float freq2 = 200.001;
//    __block float phase = 0.0;
//    __block float phase2 = 0.0;
//    [_audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
//     {
//         
//         float samplingRate = _audioManager.samplingRate;
//         for (int i=0; i < numFrames; ++i)
//         {
//             for (int iChannel = 0; iChannel < numChannels; ++iChannel)
//             {
//                 float theta = phase * M_PI * 2;
//                 float theta2 = phase2 * M_PI * 2;
//                 float osc1 = sin(theta);
//                 float osc2 = sin(theta2);
//                 data[i*numChannels + iChannel] = (osc1 + osc2) * 0.125;
//             }
//             
//             phase += 1.0 / (samplingRate / frequency);
//             if (phase > 1.0) phase = -1.0;
//             
//             phase2 += 1.0 / (samplingRate / freq2);
//             if (phase2 > 1.0) phase2 = -1.0;
//             
//             
//         }
//     }];
}

@end
