//
//  SyncWorld.glsl
//

-- Decal.Vertex ------------------------------------------

attribute vec2 pos;
attribute vec2 st;

varying mediump vec2 stVarying;

uniform mat4 modelViewProjectionMatrix;

void main()
{
    stVarying = st;
    gl_Position = modelViewProjectionMatrix * vec4(pos.x, pos.y, 0.0, 1.0) ;
}

-- Decal.Fragment ------------------------------------------

uniform sampler2D sampler_baseTex;

varying mediump vec2 stVarying;

void main()
{
    //gl_FragColor = colorVarying;
    gl_FragColor = texture2D( sampler_baseTex, stVarying );
//    gl_FragColor = vec4( stVarying.x, 0.0, stVarying.y, 1.0 );
}

-- SoundCtr.Vertex ------------------------------------------

attribute vec2 pos;
attribute vec2 st;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;

void main()
{    
    gl_Position = modelViewProjectionMatrix * vec4(pos.x, pos.y, 0.0, 1.0) ;
}

-- SoundCtr.Fragment ------------------------------------------

varying lowp vec4 colorVarying;

void main()
{
    //gl_FragColor = colorVarying;
    gl_FragColor = vec4( 0.5, 0.0, 1.0, 1.0 );
}