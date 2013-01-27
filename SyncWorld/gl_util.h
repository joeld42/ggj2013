#ifndef OKE_GL_UTILS
#define OKE_GL_UTILS

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

// Stuff that is useful in GL

// -------------------------------------------------------------------------
//  GL Error Checking
// -------------------------------------------------------------------------
const GLubyte* _gluErrorString(GLenum errorCode);

int _checkForGLErrors( const char *s, const char * file, int line );

// TODO: make go away in final release build
#define CHECKGL( msg ) _checkForGLErrors( msg, __FILE__, __LINE__ )
#define CHECKGLERR  _checkForGLErrors( "GL Error", __FILE__, __LINE__ )

#endif

