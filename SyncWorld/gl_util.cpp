
#include <stdio.h>
#include <stdint.h>

#include "gl_util.h"


// ---------------------------------------------------------------------------
#pragma mark - Error Checking
// ---------------------------------------------------------------------------

// Adapted from Mesa...
struct TokenDesc
{
    GLuint token;
    const char *desc;
};

static const struct TokenDesc errorDesc[] = {
    { GL_NO_ERROR, "no error" },
    { GL_INVALID_ENUM, "invalid enumerant" },
    { GL_INVALID_VALUE, "invalid value" },
    { GL_INVALID_OPERATION, "invalid operation" },
    { GL_STACK_OVERFLOW, "stack overflow" },
    { GL_STACK_UNDERFLOW, "stack underflow" },
    { GL_OUT_OF_MEMORY, "out of memory" },
#ifdef GL_EXT_framebuffer_object
    { GL_INVALID_FRAMEBUFFER_OPERATION_EXT, "invalid framebuffer operation" },
#endif
    { static_cast<GLuint>(~0), NULL } /* end of list indicator */
};


const GLubyte* 
_gluErrorString(GLenum errorCode)
{
    int i;
    for (i = 0; errorDesc[i].desc; i++) {
        if (errorDesc[i].token == errorCode)
            return (const GLubyte *) errorDesc[i].desc;
    }
    return (const GLubyte *) 0;
}

int _checkForGLErrors( const char *s, const char * file, int line )
{

    int errors = 0 ;
    int counter = 0 ;
    
    while ( counter < 1000 )
    {
        GLenum x = glGetError() ;
        
        if ( x == GL_NO_ERROR )
            return errors ;
        
        const GLubyte *errMsg = _gluErrorString( x );
        
        printf( "%s:%d OpenGL error: %s; %s [%d]\n",
                   file, line,
                   s ? s : "", errMsg, x ) ;
        
        errors++ ;
        counter++ ;
    }
    return 0;
}

//+ (GLuint)makeGLTexture:(void*)data width:(uint32_t)width height:(uint32_t)height convert5551:(BOOL)doConvert
GLuint makeGLTexture( void *data, uint32_t width, uint32_t height, bool convert5551 )
{
    GLuint texId;

    // Convert 8888 texture to 5551 in-place
    if (convert5551)
    {
        uint8_t *src = (uint8_t*)data;
        uint16_t *dest = (uint16_t *)data;

        for (int j=0; j < height; j++)
        {
            for (int i=0; i < width; i++)
            {
                uint8_t r,g,b,a;
                r = src[0];
                g = src[1];
                b = src[2];
                a = src[3];

                *dest = ((r>>3)<<11) | ((g>>3)<<6) | ((b>>3)<<1) | (a>>7);

                dest++;
                src += 4;
            }
        }
    }

    glGenTextures(1, &texId );
    glBindTexture(GL_TEXTURE_2D, texId);

    if (convert5551)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
    }
    else
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    }

    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );

    glGenerateMipmapOES(GL_TEXTURE_2D);

    CHECKGL( "makeGLTexture");

    return texId;

}



