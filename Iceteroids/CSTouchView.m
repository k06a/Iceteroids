//
//  CSTouchView.m
//  Iceteroids
//
//  Created by Антон Буков on 27.01.14.
//  Copyright (c) 2014 Codeless Solutions. All rights reserved.
//

#import "CSTouchView.h"

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

    self.touchingLeft = touchLeft;
    self.touchingRight = touchRight;
    self.touchingForward = touchForward;
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
