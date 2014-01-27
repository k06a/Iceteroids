//
//  CSTouchView.m
//  Iceteroids
//
//  Created by Антон Буков on 27.01.14.
//  Copyright (c) 2014 Codeless Solutions. All rights reserved.
//

#import "CSTouchView.h"

@interface CSTouchView ()
@property (assign, nonatomic) BOOL wasLeft;
@property (assign, nonatomic) BOOL wasRight;
@property (assign, nonatomic) BOOL wasForward;
@end

@implementation CSTouchView

- (void)do:(NSSet *)touches
{
    CGFloat w = self.bounds.size.width;
    BOOL touchLeft = NO;
    BOOL touchRight = NO;
    BOOL touchForward = NO;
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self];
        if (point.x <= w/2-w/6)
            touchLeft = YES;
        if (point.x >= w/2+w/6)
            touchRight = YES;
        if (w/2-w/6 < point.x && point.x < w/2+w/6)
            touchForward = YES;
    }

    BOOL needLeft = touchLeft && !touchRight;
    BOOL needRight = touchRight && !touchLeft;
    BOOL needForward = touchForward || (touchLeft && touchRight);
    
    if (needForward && !touchForward)
    {
        needLeft = NO;
        needRight = NO;
    }
    
    if (!needLeft && self.wasLeft)
        [self.doDelegate doNotRotate];
    if (!needRight && self.wasRight)
        [self.doDelegate doNotRotate];
    if (!needForward && self.wasForward)
        [self.doDelegate doNotAccelerate];
    
    if (needLeft && !self.wasLeft)
        [self.doDelegate doLeft];
    if (needRight && !self.wasRight)
        [self.doDelegate doRight];
    if (needForward && (!self.wasForward || needLeft || needRight))
        [self.doDelegate doForward];
    
    self.wasLeft = needLeft;
    self.wasRight = needRight;
    self.wasForward = needForward;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    touches = [touches setByAddingObjectsFromSet:[event allTouches]];
    [self do:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    touches = [touches setByAddingObjectsFromSet:[event allTouches]];
    [self do:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableSet *set = [[event allTouches] mutableCopy];
    [set minusSet:touches];
    [self do:set];
}

@end
