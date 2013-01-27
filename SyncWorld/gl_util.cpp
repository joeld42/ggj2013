
#include <stdio.h>

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


