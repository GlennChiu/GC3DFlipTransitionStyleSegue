//
//  This code is distributed under the terms and conditions of the zlib license.
//
//  Copyright (c) 2013 Glenn Chiu
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "GC3DFlipTransitionStyleSegue.h"
#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKit.h>

#if ! __has_feature(objc_arc)
#error GC3DFlipTransitionStyleSegue is ARC only. Use -fobjc-arc as compiler flag for this library
#endif

#ifdef DEBUG
#   define GCNRLog(fmt, ...) NSLog((@"%s [Line %d]\n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define GCNRLog(...) do {} while(0)
#endif

@interface GC3DFlipTransitionStyleViewController : GLKViewController

@property (strong, nonatomic) UIView *sourceView;
@property (strong, nonatomic) UIView *destinationView;
@property (assign, nonatomic) float depth;
@property (assign, nonatomic) BOOL disableLightEffect;
@property (assign, nonatomic) BOOL disableMultisampling;

@end

float kGC3DFlipTransitionStyle_Horizontal   = FLT_EPSILON;
float kGC3DFlipTransitionStyle_iTunesU      = 0.4f;
float kGC3DFlipTransitionStyle_iBooks       = 0.5f;

typedef struct
{
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 texture;
} Vertex;

static const Vertex _verticesInit[] =
{
    // Source
    {{ 1.0f,  1.0f, -0.25f}, {0.0f, 0.0f, -1.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -1.0f, -0.25f}, {0.0f, 0.0f, -1.0f}, {0.0f, 0.0f}},
    {{-1.0f, -1.0f, -0.25f}, {0.0f, 0.0f, -1.0f}, {1.0f, 0.0f}},
    {{-1.0f,  1.0f, -0.25f}, {0.0f, 0.0f, -1.0f}, {1.0f, 1.0f}},
    // Destination
    {{-1.0f,  1.0f,  0.25f}, {0.0f, 0.0f,  1.0f}, {0.0f, 1.0f}},
    {{-1.0f, -1.0f,  0.25f}, {0.0f, 0.0f,  1.0f}, {0.0f, 0.0f}},
    {{ 1.0f, -1.0f,  0.25f}, {0.0f, 0.0f,  1.0f}, {1.0f, 0.0f}},
    {{ 1.0f,  1.0f,  0.25f}, {0.0f, 0.0f,  1.0f}, {1.0f, 1.0f}},
    // Side
    {{ 1.0f, -1.0f, -0.25f}, {1.0f, 0.0f,  0.0f}, {1.0f, 0.0f}},
    {{ 1.0f,  1.0f, -0.25f}, {1.0f, 0.0f,  0.0f}, {1.0f, 1.0f}},
    {{ 1.0f,  1.0f,  0.25f}, {1.0f, 0.0f,  0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -1.0f,  0.25f}, {1.0f, 0.0f,  0.0f}, {0.0f, 0.0f}},
};

@implementation GC3DFlipTransitionStyleViewController
{
    EAGLContext *_context;
    GLuint _vertexArray, _vertexBuffer;
    GLKBaseEffect *_effect;
    GLfloat _rotation, _elapsedTime;
    GLKTextureInfo *_infoSource, *_infoDestination, *_infoSide;
    UIImage *_snapshotSource;
    UIImageView *_snapshotView;
    Vertex _vertices[sizeof(_verticesInit)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->_snapshotSource = [self snapshotFromView:self.sourceView];
    
    self->_snapshotView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    self->_snapshotView.image = self->_snapshotSource;
    self->_snapshotView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self->_snapshotView];
    
    self->_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    assert(self->_context);
    
    GLKView *view = (GLKView *)self.view;
    view.context = self->_context;
    view.drawableMultisample = self.disableMultisampling ? GLKViewDrawableMultisampleNone : GLKViewDrawableMultisample4X;
    
    self.preferredFramesPerSecond = 60;
    
    [self setupVertices];
    
    [self setupGL];
}

- (void)dealloc
{
    [self tearDownGL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && self.view.window == nil)
    {
        self.view = nil;
        [self tearDownGL];
    }
}

- (void)setupVertices
{
    memcpy(self->_vertices, _verticesInit, sizeof(_verticesInit));
    
    if (!self.depth) self.depth = kGC3DFlipTransitionStyle_iBooks;
    
    self.depth = fabsf(self.depth) / 2.0f;
    
    for (int i = 0; i < sizeof(self->_vertices) / sizeof(self->_vertices[0]); i++)
    {
        if (i < 4 || i == 8 || i == 9)
            self->_vertices[i].position.z = -1.0f * self.depth;
        else
            self->_vertices[i].position.z = self.depth;
    }
}

- (GLKTextureInfo *)setupTextureFromCGImage:(CGImageRef)image contentsOfFile:(NSString *)file
{
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @YES};
    NSError *error = nil;
    GLKTextureInfo *info = nil;
    
    if (image)
        info = [GLKTextureLoader textureWithCGImage:image options:options error:&error];
    else if (file)
        info = [GLKTextureLoader textureWithContentsOfFile:file options:options error:&error];
    
    if (!info) GCNRLog(@"Error loading texture: %@", error.localizedDescription);
    
    return info;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self->_context];
    
    self->_infoSource = [self setupTextureFromCGImage:[self->_snapshotSource CGImage] contentsOfFile:nil];
    
    self->_infoDestination = [self setupTextureFromCGImage:[[self snapshotFromView:self.destinationView] CGImage] contentsOfFile:nil];
    
    self->_infoSide = [self setupTextureFromCGImage:NULL contentsOfFile:[[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_TYPE]];
    
    self->_effect = [[GLKBaseEffect alloc] init];
    
    self->_effect.light0.enabled = !self.disableLightEffect;
    self->_effect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self->_effect.light0.ambientColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    self->_effect.light0.position = GLKVector4Make(0.0f, 0.0f, 1.0f, 0.0f);
    
    self->_effect.texture2d0.enabled = GL_TRUE;
    self->_effect.texture2d0.target = self->_infoSource.target;
    
    glEnable(GL_CULL_FACE);
    
    glGenVertexArraysOES(1, &self->_vertexArray);
    glBindVertexArrayOES(self->_vertexArray);
    
    glGenBuffers(1, &self->_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, self->_vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(self->_vertices), self->_vertices, GL_STATIC_DRAW);
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self->_context];
    
    glDeleteBuffers(1, &self->_vertexBuffer);
    glDeleteVertexArraysOES(1, &self->_vertexArray);
    
    [EAGLContext setCurrentContext:nil];
    
    self->_context = nil;
    self->_effect = nil;
    self->_snapshotSource = nil;
}

- (UIImage *)snapshotFromView:(UIView *)view
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect texRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds));
    
    UIGraphicsBeginImageContextWithOptions(texRect.size, YES, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static inline GLfloat GCSinusoidalEaseInOut(GLclampf t)
{
    return -0.5f * cosf(M_PI * t) -0.5f;
}

static inline GLfloat GCSinusoidalTranslation(GLclampf r)
{
    return sinf(r * M_PI) * 0.5f;
}

- (void)update
{
    GLfloat aspect = fabsf(CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds));
    GLfloat fovyRadians = GLKMathDegreesToRadians(20.0f);
    GLfloat tz = 1.0f / tanf(fovyRadians/2.0f) + self.depth;
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fovyRadians, aspect, 0.1f, 10.0f);
    self->_effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -tz + GCSinusoidalTranslation(self->_rotation));
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, aspect, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, self->_rotation * M_PI, 0.0f, 1.0f, 0.0f);
    self->_effect.transform.modelviewMatrix = modelViewMatrix;
    
    self->_elapsedTime += self.timeSinceLastUpdate * 0.9f;
    
    if (self->_elapsedTime >= 1.0f) self->_elapsedTime = 1.0f;
    
    self->_rotation = GCSinusoidalEaseInOut(self->_elapsedTime);
    
    if (self->_elapsedTime == 1.0f)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self dismissViewControllerAnimated:NO completion:nil];
        });
    }
    
    if (self->_snapshotView && self->_elapsedTime)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self->_snapshotView removeFromSuperview];
            self->_snapshotView = nil;
        });
    }
}

- (void)drawArrayWithTexture:(GLuint)name offset:(GLint)offset
{
    self->_effect.texture2d0.name = name;
    [self->_effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLE_FAN, offset, 4);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, position));
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, normal));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, texture));
    
    [self drawArrayWithTexture:self->_infoSource.name offset:0];
    [self drawArrayWithTexture:self->_infoDestination.name offset:4];
    [self drawArrayWithTexture:self->_infoSide.name offset:8];
}

@end

@implementation GC3DFlipTransitionStyleSegue

- (void)perform
{
    GC3DFlipTransitionStyleViewController *flipViewController = [[GC3DFlipTransitionStyleViewController alloc] init];
    
    flipViewController.sourceView = [self.sourceViewController view];
    flipViewController.destinationView = [self.destinationViewController view];
    flipViewController.disableMultisampling = self.disableMultisampling;
    flipViewController.disableLightEffect = self.disableLightEffect;
    flipViewController.depth = self.depth;
    
    [self.sourceViewController presentViewController:self.destinationViewController animated:NO completion:nil];
    [self.destinationViewController presentViewController:flipViewController animated:NO completion:nil];
}

@end
