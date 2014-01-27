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

@interface CSViewController () <CSTouchViewDelegate>
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
        _spaceship.deceleration = 0.95;
    }
    return _spaceship;
}

- (NSMutableArray *)asteroids
{
    if (_asteroids == nil)
        _asteroids = [NSMutableArray array];
    return _asteroids;
}

- (void)doLeft
{
    self.spaceship.rotAcceleration = 2;
}

- (void)doRight
{
    self.spaceship.rotAcceleration = -2;
}

- (void)doForward
{
    self.spaceship.acceleration = GLKVector2Make(100*cos(self.spaceship.angle+M_PI_2),
                                                 100*sin(self.spaceship.angle+M_PI_2));
}

- (void)doNotRotate
{
    self.spaceship.rotAcceleration = 0;
}

- (void)doNotAccelerate
{
    self.spaceship.acceleration = GLKVector2Make(0,0);
}

- (CSGameSprite *)generateAsteroid
{
    CSGameSprite *asteroid = [[CSGameSprite alloc] initWithImage:[UIImage imageNamed:@"blue_ball"] effect:self.effect];
    asteroid.deceleration = 0;
    asteroid.scale = 1.0 + (rand()%100)/50.0;
    
    NSInteger w = self.view.bounds.size.width;
    NSInteger h = self.view.bounds.size.height;
    asteroid.position = GLKVector2Make((rand()%200-100+w)%w, (rand()%200-100+h)%h);
    asteroid.velocity = GLKVector2Make(rand()%200-100, rand()%200-100);
    
    return asteroid;
}

- (void)viewDidLayoutSubviews
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, self.view.bounds.size.width, 0, self.view.bounds.size.height, -1024, 1024);
        self.effect.transform.projectionMatrix = projectionMatrix;
        for (int i = 0; i < 10; i++)
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
    view.doDelegate = self;
    
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

void kick(double m1, double m2, double u1, double u2, double *v1, double *v2)
{
    double imp = m1*u1 + m2*u2;
    double pow = m1*u1*u1 + m2*u2*u2;
    double a = m2*(m2+1);
    double b = 2*imp*m2/m1;
    double c = imp*imp/m1 - pow;
    double sqrt_d = sqrt(b*b - 4*a*c);
    double x1 = (- b - sqrt_d)/(2*a);
    double x2 = (- b + sqrt_d)/(2*a);
    double y1 = (imp - m2*x1)/m1;
    double y2 = (imp - m2*x2)/m1;
    
    NSLog(@"%f %f %f %f", x1, x2, y1, y2);
}

- (void)update
{
    CGFloat dt = self.timeSinceLastUpdate;
    
    [self.spaceship update:dt];
    for (CSGameSprite *asteroid in self.asteroids)
        [asteroid update:dt];
    
    NSInteger w = self.view.bounds.size.width;
    NSInteger h = self.view.bounds.size.height;
    for (CSGameSprite *sprite in [self.asteroids arrayByAddingObject:self.spaceship])
    {
        if (sprite.position.x < -100 || sprite.position.x > w+100)
            sprite.position = GLKVector2Make(w-sprite.position.x, sprite.position.y);
        if (sprite.position.y < -100 || sprite.position.y > h+100)
            sprite.position = GLKVector2Make(sprite.position.x, h-sprite.position.y);
    }
    
    for (CSGameSprite *sprite1 in self.asteroids) {
        for (CSGameSprite *sprite2 in self.asteroids) {
            if (sprite1 == sprite2)
                continue;
            
            CGFloat dist = (sprite1.position.x - sprite2.position.x)
                            *(sprite1.position.x - sprite2.position.x)
                         + (sprite1.position.y - sprite2.position.y)
                            *(sprite1.position.y - sprite2.position.y);
            
            if (dist + 0.05 < sprite1.radius + sprite2.radius)
            {
                double vx1, vx2;
                kick(1, 1, sprite1.velocity.x, sprite2.velocity.x, &vx1, &vx2);
                double vy1, vy2;
                kick(1, 1, sprite1.velocity.y, sprite2.velocity.y, &vy1, &vy2);
            }
        }
    }
}

@end
