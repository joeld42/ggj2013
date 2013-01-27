//
//  SampleBuffer.m
//  SyncWorld
//
//  Created by Joel Davis on 1/26/13.
//  Copyright (c) 2013 Tapnik. All rights reserved.
//

#import <GLKit/GLKit.h>
#include "gl_util.h"

#import "SampleBuffer.h"
#import "AudioFileReader.h"


@implementation SampleBuffer

@synthesize numFrames=_numFrames;
@synthesize data=_data;
@synthesize texWaveformPreview=_texWaveformPreview;

- (id) initFromFile: (NSString*)filename
{
    self = [super init];
    if (self)
    {
        NSLog( @"Loading sound file %@", filename );
        
        NSURL *sampleUrl = [NSURL fileURLWithPath:filename ];
        CFURLRef url = (__bridge CFURLRef)sampleUrl;
        ExtAudioFileRef eaf;
        OSStatus err = ExtAudioFileOpenURL((CFURLRef)url, &eaf);
        if(noErr != err)
        {
            NSLog( @"Error reading file...");
        }
        
        AudioStreamBasicDescription format;
        format.mSampleRate = 44100;
        
        format.mFormatID = kAudioFormatLinearPCM;
        format.mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
        format.mBitsPerChannel = 32;
//        format.mFormatID = kAudioFormatLinearPCM;
//        format.mFormatFlags = kAudioFormatFlagIsPacked;
//        format.mBitsPerChannel = 16;
        format.mChannelsPerFrame = 2;
        format.mBytesPerFrame = format.mChannelsPerFrame * 4;
        format.mFramesPerPacket = 1;
        format.mBytesPerPacket = format.mFramesPerPacket * format.mBytesPerFrame;
        
        err = ExtAudioFileSetProperty(eaf, kExtAudioFileProperty_ClientDataFormat, sizeof(format), &format);
        
        UInt32 dataSize = 0;
        AudioStreamBasicDescription inputFileFormat;
        ExtAudioFileGetProperty( eaf, kExtAudioFileProperty_FileDataFormat, &dataSize, &inputFileFormat);
        
        SInt64 numFrames = 0;
        dataSize = sizeof(numFrames);
        err = ExtAudioFileGetProperty(eaf, kExtAudioFileProperty_FileLengthFrames, &dataSize, &numFrames);

        
        NSLog( @"numFrames is %lld", numFrames );
        
        /* Read the file contents using ExtAudioFileRead */        
        UInt32 outputBufferSize = format.mBytesPerFrame * numFrames;
        AudioBufferList bufList;
        bufList.mNumberBuffers = 1;
        bufList.mBuffers[0].mNumberChannels = 2;
        bufList.mBuffers[0].mDataByteSize = outputBufferSize;
        bufList.mBuffers[0].mData = (void*)malloc( outputBufferSize );
        UInt32 fileNumFrames = outputBufferSize / format.mBytesPerPacket;
        NSLog( @"fileNumFrames is %ld bytesPerPacket is %ld", fileNumFrames, format.mBytesPerPacket);
        ExtAudioFileRead(eaf, &fileNumFrames, &bufList );
        
        NSLog( @"read %ld frames", fileNumFrames);
        
        _numFrames = fileNumFrames;
        _data = (float*)bufList.mBuffers[0].mData;
        
    }
    return self;
}

- (GLuint)texWaveformPreview
{
    // Already have a preview texture?
    if (_texWaveformPreview)
    {
        return _texWaveformPreview;
    }

    // Nope, create one
    const uint32_t kWaveformWidth = 512;
    const uint32_t kWaveformHeight = 128;

    uint32_t *waveTextureData = (uint32_t*) malloc(sizeof(uint32_t) * kWaveformHeight * kWaveformWidth );


    GLKVector3 waveColorBrite = GLKVector3Make( 228.0/255.0,245.0/255.0,177.0/255.0 );
    GLKVector3 waveColorDim = GLKVector3Make( 186.0/255.0,149.0/255.0,60.0/255.0 );
    GLKVector3 waveColorBG = GLKVector3Make( 81.0/255.0,43.0/255.0,82.0/255.0 );
//    GLKVector3 waveColorBrite = GLKVector3Make( 1.0, 1.0, 0.0 );
//    GLKVector3 waveColorDim = GLKVector3Make( 0.0, 0.0, 1.0 );
//    GLKVector3 waveColorBG = GLKVector3Make( 0.0, 0.0, 0.0 );


    float maxP = 0.0;
    float minP = 2.0;
    for (int i=0; i < kWaveformWidth; i++)
    {
        int32_t frameNdx =  ((float)i / (float)kWaveformWidth) * _numFrames;
        float pval = (fabs(_data[ frameNdx *2 ]) + fabs(_data[ frameNdx * 2 + 1])) * 0.5;

        if (pval>maxP) maxP = pval;
        if (pval<minP) minP = pval;

        GLKVector3 waveCol = GLKVector3Lerp( waveColorDim, waveColorBrite, pval );
        int level = 2 + (int)(abs( pval * kWaveformHeight ) / 2.0);

        uint32_t waveCol2 = (0xff000000) |
                         (((int)(waveCol.r * 255.0)) << 16) |
                         (((int)(waveCol.g * 255.0)) << 8) |
                         (int)(waveCol.b * 255.0);

        uint32_t waveColBG = (0xff000000) |
                        (((int)(waveColorBG.r * 255.0)) << 16) |
                        (((int)(waveColorBG.g * 255.0)) << 8) |
                        (int)(waveColorBG.b * 255.0);


        for (int j=0; j < kWaveformHeight; j++)
        {
            uint32_t col;

            if (abs(j-(kWaveformHeight/2)) < level ) {
                col = waveCol2;
            } else {
                col = waveColBG;
            }

            waveTextureData [j * kWaveformWidth + i] = col;
        }
    }

    NSLog( @"pval  max %f min %f\n",  maxP, minP );


    _texWaveformPreview = makeGLTexture( waveTextureData, kWaveformWidth, kWaveformHeight, false );
    free( waveTextureData );

    return _texWaveformPreview;
}

@end
