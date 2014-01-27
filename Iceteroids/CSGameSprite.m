//
//  CSGameSprite.m
//  Iceteroids
//
//  Created by Антон Буков on 27.01.14.
//  Copyright (c) 2014 Codeless Solutions. All rights reserved.
//

#import "CSGameSprite.h"

@interface CSGameSprite ()

@property (strong) GLKBaseEffect *effect;
@property (assign) TexturedQuad quad;
@property (strong) GLKTextureInfo *textureInfo;

- (void)initQuadAndSize;

@end

@implementation CSGameSprite

- (CGFloat)scale
{
    if (_scale == 0.0)
        _scale = 1.0;
    return _scale;
}

- (void)update:(float)dt
{
    self.velocity = GLKVector2Add(self.velocity, GLKVector2MultiplyScalar(self.acceleration, dt));
    self.velocity = GLKVector2Subtract(self.velocity, GLKVector2MultiplyScalar(self.velocity, self.deceleration*dt));
    self.position = GLKVector2Add(self.position, GLKVector2MultiplyScalar(self.velocity, dt));
    
    self.rotVelocity += self.rotAcceleration*dt;
    self.rotVelocity -= self.rotVelocity*self.deceleration*dt;
    self.angle += self.rotVelocity * dt;
}

- (CGRect)boundingRect
{
    CGRect rect = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    GLKMatrix4 modelMatrix = [self modelMatrix];
    CGAffineTransform transform = CGAffineTransformMake(modelMatrix.m00, modelMatrix.m01, modelMatrix.m10, modelMatrix.m11, modelMatrix.m30, modelMatrix.m31);
    return CGRectApplyAffineTransform(rect, transform);
}

- (CGFloat)radius
{
    return self.contentSize.width/2*self.scale;
}

- (id)initWithTexture:(GLKTextureInfo *)textureInfo effect:(GLKBaseEffect *)effect
{
    if ((self = [super init]))
    {
        self.effect = effect;
        
        self.textureInfo = textureInfo;
        if (self.textureInfo == nil) {
            NSLog(@"Error loading texture! Texture info is nil!");
            return nil;
        }
        
        [self initQuadAndSize];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image effect:(GLKBaseEffect *)effect
{
    NSError *error;
    if ((self = [self initWithTexture:[GLKTextureLoader textureWithCGImage:image.CGImage options:@{GLKTextureLoaderOriginBottomLeft:@YES} error:&error] effect:effect]))
    {
        if (self.textureInfo == nil)
        {
            NSLog(@"Error loading image: %@", [error localizedDescription]);
            return nil;
        }
    }
    return self;
}

- (void)initQuadAndSize
{
    self.contentSize = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
    
    TexturedQuad newQuad;
    newQuad.bl.geometryVertex = CGPointMake(0, 0);
    newQuad.br.geometryVertex = CGPointMake(self.textureInfo.width, 0);
    newQuad.tl.geometryVertex = CGPointMake(0, self.textureInfo.height);
    newQuad.tr.geometryVertex = CGPointMake(self.textureInfo.width, self.textureInfo.height);
    
    newQuad.bl.textureVertex = CGPointMake(0, 0);
    newQuad.br.textureVertex = CGPointMake(1, 0);
    newQuad.tl.textureVertex = CGPointMake(0, 1);
    newQuad.tr.textureVertex = CGPointMake(1, 1);
    self.quad = newQuad;
}

- (GLKMatrix4)modelMatrix
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, 0);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, self.angle, 0, 0, 1);
    modelMatrix = GLKMatrix4Translate(modelMatrix, -self.contentSize.width / 2, -self.contentSize.height / 2, 0);
    modelMatrix = GLKMatrix4Scale(modelMatrix, self.scale, self.scale, 0);
    
    return modelMatrix;
}

#undef offsetof
#define offsetof(T,f) ((int)(&((T*)0)->f))

- (void)render
{
    self.effect.texture2d0.name = self.textureInfo.name;
    self.effect.texture2d0.enabled = YES;
    self.effect.transform.modelviewMatrix = [self modelMatrix];
    [self.effect prepareToDraw];
    long offset = (long)&_quad;
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
