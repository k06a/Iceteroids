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
    CGFloat w = self.bounds.size.width/2;
    BOOL haveLeft = NO;
    BOOL haveRight = NO;
    BOOL haveForward = NO;
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self];
        if (point.x <= w/2-w/6)
            haveRight = YES;
        if (point.x >= w/2+w/6)
            haveLeft = YES;
        if (w/2-w/6 < point.x && point.x < w/2+w/6)
            haveForward = YES;
    }
    
    if (haveLeft != self.wasLeft
        || haveRight != self.wasRight
        || haveForward != self.wasForward)
    {
        [self.doDelegate doNothing];
    }
    
    if (haveForward || (haveLeft && haveRight))
        return [self.doDelegate doForward];
    if (haveLeft)
        return [self.doDelegate doLeft];
    if (haveRight)
        return [self.doDelegate doRight];
    
    self.wasLeft = haveLeft;
    self.wasRight = haveRight;
    self.wasForward = haveForward;
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
    touches = [touches setByAddingObjectsFromSet:[event allTouches]];
    [self do:touches];
    [self.doDelegate doNothing];
}

@end
