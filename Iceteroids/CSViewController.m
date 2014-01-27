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

- (void)viewDidLayoutSubviews
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, self.view.bounds.size.width, 0, self.view.bounds.size.height, -1024, 1024);
        self.effect.transform.projectionMatrix = projectionMatrix;
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

- (void)update
{
    [self.spaceship update:self.timeSinceLastUpdate];
}

@end
