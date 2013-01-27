//
//  SampleBuffer.m
//  SyncWorld
//
//  Created by Joel Davis on 1/26/13.
//  Copyright (c) 2013 Tapnik. All rights reserved.
//

#import "SampleBuffer.h"

#import "AudioFileReader.h"

@implementation SampleBuffer

@synthesize numFrames=_numFrames;
@synthesize data=_data;

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

@end
