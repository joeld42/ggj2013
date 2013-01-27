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
#import "SoundCenter.h"
#import "gl_util.h"
#import "glsw.h"
#import "shader.h"

@interface SyncWorldGame ()
{
    BOOL _doneInit;
    
    // Graphics resources
    GLKMatrix4 _modelViewProjectionMatrix;
    
    GLuint _progSoundCtr;
    GLuint _uparamSoundCtr_modelViewProjection;

    GLuint _progDecal;
    GLuint _uparamDecal_modelViewProjection;
    GLuint _uparamDecal_baseTex;
    
    GLKTextureInfo *_texIdSoundIcons;
    
    // Audio resources
    RingBuffer *_ringBuffer;
    Novocaine *_audioManager;

    SampleBuffer *_testSample;

    NSMutableArray *_soundCtrs;
}

- (GLKTextureInfo *)_loadTexture: (NSString*)textureName;

- (void) _initGame;

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
//    NSString *samplePath = [[NSBundle mainBundle] pathForResource:@"piano_notes" ofType:@"wav"];
//    NSString *samplePath = [[NSBundle mainBundle] pathForResource:@"170406__wind-chimes" ofType:@"wav"];
//    NSString *samplePath = [[NSBundle mainBundle] pathForResource:@"18749__lg__copier04" ofType:@"wav"];
    NSString *samplePath = [[NSBundle mainBundle] pathForResource:@"50405__daddoit__chimes-part-6" ofType:@"wav"];
    
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

- (void)_initGame
{
    _doneInit = YES;

    // Init view
    _modelViewProjectionMatrix = GLKMatrix4MakeOrtho(0, 1024, 0, 768, -1.0, 1.0);
    
    // Init shaders
    NSString *resPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString: @"/"];
    glswInit();
    glswSetPath( [resPath UTF8String], ".glsl" );
    
    _progSoundCtr = loadShader( "SyncWorld.SoundCtr");
    _uparamSoundCtr_modelViewProjection = glGetUniformLocation(_progSoundCtr, "modelViewProjectionMatrix");
    NSLog( @"Loaded shader _progSoundCtr (%d)", _progSoundCtr );
    
    _progDecal = loadShader( "SyncWorld.Decal");
    _uparamDecal_modelViewProjection = glGetUniformLocation( _progDecal, "modelViewProjectionMatrix");
    _uparamDecal_baseTex = glGetUniformLocation( _progDecal, "sampler_baseTex");
    
    // Init textures
    _texIdSoundIcons = [self _loadTexture: @"sound_icons" ];
    
    // Init samples
    NSString *samplePath = [[NSBundle mainBundle] pathForResource:@"GGJ13_Theme" ofType:@"wav"];
    NSLog( @"Sample path is %@", samplePath );
    _testSample = [[SampleBuffer alloc] initFromFile:samplePath];

    // Make a SoundCenter from this
    SoundCenter *ctrHeart = [[SoundCenter alloc] initWithSample:_testSample];
    
    // Our centers
    _soundCtrs = [NSMutableArray array];
    [_soundCtrs addObject:ctrHeart ];
}

- (void) update: (CFTimeInterval)dt
{
//    NSLog( @"update: %f", dt );
}

- (void) render
{
    // Init first render (GL ctx active)
    if (!_doneInit) [self _initGame];
    
    glClearColor(0.2f, 0.2f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // ====== Draw all of the sound centers
    
    // Draw the decals
    glUseProgram( _progDecal );
    glUniformMatrix4fv( _uparamDecal_modelViewProjection, 1, 0, _modelViewProjectionMatrix.m);
    glBindTexture( GL_TEXTURE_2D, _texIdSoundIcons.name );
	
	glUniform1i( _uparamDecal_baseTex, 0 );

    
    for (SoundCenter *ctr in _soundCtrs)
    {
        [ctr drawIcon];
    }
    
    // Draw the waveform parts
    glUseProgram( _progSoundCtr );
    glUniformMatrix4fv( _uparamSoundCtr_modelViewProjection, 1, 0, _modelViewProjectionMatrix.m);
    
    for (SoundCenter *ctr in _soundCtrs)
    {
        [ctr drawWaveform];
    }

    CHECKGL( "render done");
}

- (GLKTextureInfo *) _loadTexture: (NSString*)textureName
{
    NSError *error = nil;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:textureName ofType:@"png"];
    NSLog( @"Loading texture at path %@", path );
    
    GLKTextureInfo *texInfo =  [GLKTextureLoader textureWithContentsOfFile:path
                                                   options:nil error:&error];
    
    if (!texInfo)
    {
        NSLog( @"Failed to load texture '%@', error: %@", textureName, error );
    }
    
    return texInfo;
}

@end
