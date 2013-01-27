//
//  SoundCenter.m
//  SyncWorld
//
//  Created by Joel Davis on 1/26/13.
//  Copyright (c) 2013 Tapnik. All rights reserved.
//

#import "SoundCenter.h"
#import "SampleBuffer.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define NUM_SEGMENTS (30)

struct SoundCenterVert
{
    GLKVector2 pos;
    GLKVector2 st;
};

@interface SoundCenter ()
{
    BOOL _dirty;

    GLuint _vboIcon;
    GLuint _vertexBufferIcon;

    GLuint _vboWaveform;
    GLuint _vertexBufferWaveform;

    
    SoundCenterVert *_vertDataRing;
    SoundCenterVert *_vertDataIcon;
}

@property (nonatomic, strong) SampleBuffer *sample;

- (void) _build;

@end

@implementation SoundCenter

@synthesize sample=_sample;

@synthesize center=_center;
@synthesize radius=_radius;
@synthesize iconIndex=_iconIndex;

- (id)initWithSample: (SampleBuffer *)buffer
{
    self = [super init];
    if (self)
    {
        self.sample = buffer;

        self.center = GLKVector2Make( 512.0, 369.0 );
        self.radius = 150.0;
        _dirty = YES;
    }
    return self;
}

- (void)drawIcon
{
    if (_dirty)
    {
        [self _build];
    }
    
    //NSLog( @"Drawing soundCenter Icon: (vbo %d)", _vboIcon);
    
    glBindVertexArrayOES(_vboIcon);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4 );
    
    glBindVertexArrayOES(0);
}

- (void)drawWaveform
{
    if (_dirty)
    {
        [self _build];
    }
    
    glBindVertexArrayOES(_vboWaveform );
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);

    glBindTexture(GL_TEXTURE_2D, _sample.texWaveformPreview );
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (NUM_SEGMENTS * 2) );
    
    glBindVertexArrayOES(0);
}


- (void) _build
{
    _dirty = NO;
    
    // ------------------
    // Build waveform
    // ------------------
    if (_vertDataRing) delete _vertDataRing;
    _vertDataRing = new SoundCenterVert[ NUM_SEGMENTS * 2 ];
    
    for (int i = 0; i < NUM_SEGMENTS; i++)
    {
        float tval = ((float)i / (NUM_SEGMENTS-1));
        float ang =  tval * (2*M_PI);
        GLKVector2 dir = GLKVector2Make( cos(ang), sin(ang) );
        _vertDataRing[i*2+0].pos = GLKVector2Make( _center.x + (dir.x * _radius*0.5),
                                                   _center.y + (dir.y * _radius*0.5) ); // inner
        _vertDataRing[i*2+0].st = GLKVector2Make( tval, 0.0 );
        
        _vertDataRing[i*2+1].pos = GLKVector2Make( _center.x + (dir.x * _radius*1.0),
                                                   _center.y + (dir.y * _radius*1.0) ); // outer
        _vertDataRing[i*2+1].st = GLKVector2Make( tval, 1.0 );

    }
    
    // Generate our VBO (todo: reuse vbo if we're modifying this)
    glGenVertexArraysOES(1, &_vboWaveform);
    glBindVertexArrayOES(_vboWaveform);
    
    glGenBuffers(1, &_vertexBufferWaveform);
       
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferWaveform );
    glBufferData(GL_ARRAY_BUFFER, sizeof(SoundCenterVert) * (NUM_SEGMENTS * 2), _vertDataRing, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(SoundCenterVert), BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SoundCenterVert), BUFFER_OFFSET(8));
    
    // ------------------
    // Build Icon
    // ------------------
    if (_vertDataIcon) delete _vertDataIcon;
    _vertDataIcon = new SoundCenterVert[ 4 ];
    
    float rv = (_radius * 0.5 );
    float iconSz = 1.0 / 8.0; // 8x8 icons up on texture
    float iconS = (_iconIndex / 8) * iconSz;
    float iconT = (_iconIndex % 8) * iconSz;
    _vertDataIcon[0].pos = GLKVector2Make( _center.x -1.0 * rv, _center.y -1.0 * rv );
    _vertDataIcon[0].st = GLKVector2Make( iconS, iconT + iconSz );

    _vertDataIcon[1].pos = GLKVector2Make( _center.x + 1.0 * rv, _center.y -1.0 * rv );
    _vertDataIcon[1].st = GLKVector2Make( iconS + iconSz, iconT + iconSz );

    _vertDataIcon[2].pos = GLKVector2Make( _center.x -1.0 * rv, _center.y + 1.0 * rv );
    _vertDataIcon[2].st = GLKVector2Make( iconS, iconT );
    
    _vertDataIcon[3].pos = GLKVector2Make( _center.x + 1.0 * rv, _center.y + 1.0 * rv );
    _vertDataIcon[3].st = GLKVector2Make( iconS + iconSz, iconT );

    
    // Generate our VBO (todo: reuse vbo if we're modifying this)
    glGenVertexArraysOES(1, &_vboIcon);
    glBindVertexArrayOES(_vboIcon);
    
    glGenBuffers(1, &_vertexBufferIcon);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferIcon );
    glBufferData(GL_ARRAY_BUFFER, sizeof(SoundCenterVert) * 4, _vertDataIcon, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(SoundCenterVert), BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SoundCenterVert), BUFFER_OFFSET(8));
    
    glBindVertexArrayOES(0);    
}

@end
