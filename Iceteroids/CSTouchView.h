//
//  CSTouchView.h
//  Iceteroids
//
//  Created by Антон Буков on 27.01.14.
//  Copyright (c) 2014 Codeless Solutions. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface CSTouchView : GLKView
@property (assign, nonatomic) BOOL touchingLeft;
@property (assign, nonatomic) BOOL touchingRight;
@property (assign, nonatomic) BOOL touchingForward;
@end
