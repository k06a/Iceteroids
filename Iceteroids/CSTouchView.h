//
//  CSTouchView.h
//  Iceteroids
//
//  Created by Антон Буков on 27.01.14.
//  Copyright (c) 2014 Codeless Solutions. All rights reserved.
//

#import <GLKit/GLKit.h>

@protocol CSTouchViewDelegate <NSObject>
- (void)doRight;
- (void)doLeft;
- (void)doForward;
- (void)doNotRotate;
- (void)doNotAccelerate;
@end

@interface CSTouchView : GLKView
@property (weak, nonatomic) id<CSTouchViewDelegate> doDelegate;
@end
