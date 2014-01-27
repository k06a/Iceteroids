//
//  CSGameSprite.h
//  Iceteroids
//
//  Created by Антон Буков on 27.01.14.
//  Copyright (c) 2014 Codeless Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct
{
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct
{
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;
} TexturedQuad;

@interface CSGameSprite : NSObject

- (id)initWithTexture:(GLKTextureInfo *)textureInfo effect:(GLKBaseEffect *)effect;
- (id)initWithImage:(UIImage *)image effect:(GLKBaseEffect *)effect;
- (void)render;
- (void)update:(float)dt;
- (CGRect)boundingRect;

@property (assign, nonatomic) CGSize contentSize;

@property (assign, nonatomic) CGFloat deceleration; // like 0.8-0.9

@property (assign, nonatomic) GLKVector2 position;
@property (assign, nonatomic) GLKVector2 velocity;
@property (assign, nonatomic) GLKVector2 acceleration;

@property (assign, nonatomic) CGFloat angle;
@property (assign, nonatomic) CGFloat rotVelocity;
@property (assign, nonatomic) CGFloat rotAcceleration;

@end
