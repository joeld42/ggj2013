//
// Created by joeld on 1/25/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

struct TKMeshVert
{
    GLKVector3 pos;
    GLKVector3 nrm;
    GLKVector4 st;
};

@interface TKMesh : NSObject

+ (TKMesh *)meshFromObjFile: (NSString *)filename;

@end
