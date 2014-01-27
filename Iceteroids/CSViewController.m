//
//  CSViewController.m
//  Iceteroids
//
//  Created by Антон Буков on 27.01.14.
//  Copyright (c) 2014 Codeless Solutions. All rights reserved.
//

#import "CSViewController.h"
#import "CSGameSprite.h"
#import "CSTouchView.h"

@interface CSViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) CSGameSprite *spaceship;
@property (strong, nonatomic) NSMutableArray *asteroids;

- (void)setupGL;
- (void)tearDownGL;
@end

@implementation CSViewController

- (CSGameSprite *)spaceship
{
    if (_spaceship == nil)
    {
        _spaceship = [[CSGameSprite alloc] initWithImage:[UIImage imageNamed:@"spaceship"] effect:self.effect];
        _spaceship.position = GLKVector2Make(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        _spaceship.deceleration = 0.3;
    }
    return _spaceship;
}

- (NSMutableArray *)asteroids
{
    if (_asteroids == nil)
        _asteroids = [NSMutableArray array];
    return _asteroids;
}

- (CSGameSprite *)generateAsteroid
{
    CSGameSprite *asteroid = [[CSGameSprite alloc] initWithImage:[UIImage imageNamed:@"blue_ball"] effect:self.effect];
    asteroid.deceleration = 0;
    asteroid.scale = 1.0 + (rand()%140)/100.0;
    
    NSInteger r = asteroid.boundingRect.size.width/2*asteroid.scale;
    NSInteger w = self.view.bounds.size.width;
    NSInteger h = self.view.bounds.size.height;
    while (YES)
    {
        asteroid.position = GLKVector2Make(rand()%(w-r*2)+r, rand()%(h-r*2)+r);
        
        BOOL flag = YES;
        for (CSGameSprite *sprite in [self.asteroids arrayByAddingObject:self.spaceship])
            if (CGRectIntersectsRect(sprite.boundingRect, asteroid.boundingRect))
                flag = NO;
        if (flag)
            break;
    }
    asteroid.velocity = GLKVector2Make(rand()%400-200, rand()%400-200);
    
    return asteroid;
}

- (void)viewDidLayoutSubviews
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, self.view.bounds.size.width, 0, self.view.bounds.size.height, -1024, 1024);
        self.effect.transform.projectionMatrix = projectionMatrix;
        for (int i = 0; i < 3; i++)
            [self.asteroids addObject:[self generateAsteroid]];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    srand(time(NULL));
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context)
        NSLog(@"Failed to create ES context");
    
    [self setupGL];
    
    CSTouchView *view = (CSTouchView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // initializing game state
    //self.gameRunning = NO;
    //self.gameState = kGameStateNone;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(1.f, 1.f, 1.f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    [self.spaceship render];
    for (CSGameSprite *asteroid in self.asteroids) {
        [asteroid render];
    }
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    self.effect = [[GLKBaseEffect alloc] init];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    self.effect = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

double sqr(double a)
{
    return a*a;
}

void centralKick(double m1, double m2, double u1, double u2, double *v1, double *v2)
{
    *v1 = (2*m2*u2 + (m2 - m1)*u1)/(m1 + m2);
    *v2 = (2*m1*u1 + (m1 - m2)*u2)/(m1 + m2);
}

void notCentralKick(double x1, double y1, double m1, double u1x, double u1y,
                    double x2, double y2, double m2, double u2x, double u2y,
                    double *v1x, double *v1y,
                    double *v2x, double *v2y)
{
    double angle = atan2(y2-y1,x2-x1);
    double sprite1Speed = sqrt(sqr(u1x) + sqr(u1y));
    double sprite2Speed = sqrt(sqr(u2x) + sqr(u2y));
    double sprite1Angle = atan2(u1y,u1x);
    double sprite2Angle = atan2(u2y,u2x);
    
    double alpha = sprite1Angle - angle;
    double beta = sprite2Angle - angle;
    double sprite1SpeedX = sprite1Speed*cos(alpha);
    double sprite2SpeedX = sprite2Speed*cos(beta);
    double sprite1SpeedY = sprite1Speed*sin(alpha);
    double sprite2SpeedY = sprite2Speed*sin(beta);
    
    double vx1, vx2;
    centralKick(m1, m2, sprite1SpeedX, sprite2SpeedX, &vx1, &vx2);
    
    double newSpeed1 = sqrt(sqr(sprite1SpeedY) + sqr(vx1));
    double newSpeed2 = sqrt(sqr(sprite2SpeedY) + sqr(vx2));
    double newAplha = atan2(sprite1SpeedY,vx1);
    double newBeta = atan2(sprite2SpeedY,vx2);
    
    *v1x = newSpeed1*cos(newAplha + angle);
    *v1y = newSpeed1*sin(newAplha + angle);
    *v2x = newSpeed2*cos(newBeta + angle);
    *v2y = newSpeed2*sin(newBeta + angle);
}

- (void)update
{
    CGFloat dt = self.timeSinceLastUpdate;
    
    CSTouchView *view = (id)self.view;
    if ((view.touchingLeft && view.touchingRight) || view.touchingForward)
        self.spaceship.acceleration = GLKVector2Make(100*cos(self.spaceship.angle+M_PI_2), 100*sin(self.spaceship.angle+M_PI_2));
    else
        self.spaceship.acceleration = GLKVector2Make(0,0);
    
    if (view.touchingLeft && !view.touchingRight)
        self.spaceship.rotAcceleration = 2;
    else if (view.touchingRight && !view.touchingLeft)
        self.spaceship.rotAcceleration = -2;
    else
        self.spaceship.rotAcceleration = 0;
    
    [self.spaceship update:dt];
    for (CSGameSprite *asteroid in self.asteroids)
        [asteroid update:dt];
    
    NSInteger w = self.view.bounds.size.width;
    NSInteger h = self.view.bounds.size.height;
    for (CSGameSprite *sprite in [self.asteroids arrayByAddingObject:self.spaceship])
    {
        CGFloat r = sprite.radius;
        if ((sprite.position.x <= r && sprite.velocity.x < 0)
            || (sprite.position.x >= w-1-r && sprite.velocity.x > 0))
        {
            sprite.velocity = GLKVector2Make(-sprite.velocity.x, sprite.velocity.y);
            sprite.acceleration = GLKVector2Make(-sprite.acceleration.x, sprite.acceleration.y);
        }
        if ((sprite.position.y <= r && sprite.velocity.y < 0)
            || (sprite.position.y >= h-1-r && sprite.velocity.y > 0))
        {
            sprite.velocity = GLKVector2Make(sprite.velocity.x, -sprite.velocity.y);
            sprite.acceleration = GLKVector2Make(sprite.acceleration.x, -sprite.acceleration.y);
        }
    }
    
    NSArray *asteroids = [self.asteroids arrayByAddingObject:self.spaceship];
    
    for (int i = 0; i < asteroids.count-1; i++) {
        for (int j = i+1; j < asteroids.count; j++) {
            CSGameSprite *sprite1 = asteroids[i];
            CSGameSprite *sprite2 = asteroids[j];
            
            CGFloat dist = sqrt(sqr(sprite1.position.x - sprite2.position.x)
                              + sqr(sprite1.position.y - sprite2.position.y));
            CGFloat dist2 = sqrt(sqr(sprite1.position.x + sprite1.velocity.x*dt
                                     - sprite2.position.x - sprite2.velocity.x*dt)
                               + sqr(sprite1.position.y + sprite1.velocity.y*dt
                                     - sprite2.position.y - sprite2.velocity.y*dt));
            
            if (dist < (sprite1.radius + sprite2.radius)
                && dist2 < dist)
            {
                [sprite1 update:-dt];
                [sprite2 update:-dt];
                
                double v1x, v1y;
                double v2x, v2y;
                notCentralKick(sprite1.position.x, sprite1.position.y, sprite1.radius*sprite1.radius, sprite1.velocity.x, sprite1.velocity.y,
                               sprite2.position.x, sprite2.position.y, sprite2.radius*sprite2.radius, sprite2.velocity.x, sprite2.velocity.y,
                               &v1x, &v1y, &v2x, &v2y);
                
                sprite1.velocity = GLKVector2Make(v1x, v1y);
                sprite2.velocity = GLKVector2Make(v2x, v2y);
            }
        }
    }
}

@end
