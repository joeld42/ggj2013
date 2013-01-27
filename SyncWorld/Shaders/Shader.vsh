//
//  Shader.vsh
//  SyncWorld
//
//  Created by Joel Davis on 1/25/13.
//  Copyright (c) 2013 Tapnik. All rights reserved.
//

attribute vec2 pos;
attribute vec2 st;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{    
    gl_Position = modelViewProjectionMatrix * vec4(pos.x, pos.y, 0.0, 1.0) ;
}
