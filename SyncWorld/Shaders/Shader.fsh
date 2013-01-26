//
//  Shader.fsh
//  SyncWorld
//
//  Created by Joel Davis on 1/25/13.
//  Copyright (c) 2013 Tapnik. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
