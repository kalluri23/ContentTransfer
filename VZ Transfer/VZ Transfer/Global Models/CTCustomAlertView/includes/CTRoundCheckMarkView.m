//
//  CTRoundCheckMarkView.m
//  linePoc
//
//  Created by Sun, Xin on 11/16/16.
//  Copyright © 2016 Sun, Xin. All rights reserved.
//

#import "CTRoundCheckMarkView.h"

#import <QuartzCore/QuartzCore.h>

#define vColorCheckMarkGreen [UIColor colorWithRed:76/255.f green:144/255.f blue:79/255.f alpha:1.0f]
#define vColorCheckMarkRed   [UIColor colorWithRed:205/255.f green:4/255.f blue:11/255.f alpha:1.0f]

@interface CTRoundCheckMarkView() {
    @private
    CGFloat width;
}

@property (nonatomic, strong) UIColor *greenColor;
@property (nonatomic, strong) CALayer *animationLayer;

@end

@implementation CTRoundCheckMarkView

- (void)setBgColor:(enum CheckMarkViewColor)bgColor {
    if (_bgColor != bgColor) {
        _bgColor = bgColor;
        [self setBackgroundColor:[self _matchColor:bgColor]];
    }
}

- (instancetype)initWithSize:(CGFloat)size andCenter:(CGPoint)centerPoint andColor:(enum CheckMarkViewColor)color {
    self = [super initWithFrame:CGRectMake(0, 0, size, size)];
    if (self) {
        width = size;
        
        self.center = centerPoint;
        [self setBackgroundColor:[self _matchColor:color]];
        self.layer.cornerRadius = size/2;
        self.layer.masksToBounds = YES;
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (!_withAnimate) {
        [self _drawLine];
    }
}

- (void)startDrawLine {
    [self _drawLine];
}

- (void)_drawLine {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.frame.size.width/4, self.frame.size.height/2)];
    [path addLineToPoint:CGPointMake(4*self.frame.size.width/9, 2*self.frame.size.height/3)];
    [path addLineToPoint:CGPointMake(3*self.frame.size.width/4, 3*self.frame.size.height/9)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    shapeLayer.lineWidth = width/10;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    
    [self.layer addSublayer:shapeLayer];
    
    if (_withAnimate) {
        [self _startAnimation:shapeLayer];
    }
}

- (void)_startAnimation:(CAShapeLayer *)layer {
    [layer removeAllAnimations];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.f;
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
    [layer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

- (UIColor *)_matchColor:(enum CheckMarkViewColor)_colorType {
    switch (_colorType) {
        case vCheckMarkViewColorGreen:
            return vColorCheckMarkGreen;
            break;
            
        case vCheckMarkViewColorRed:
            return vColorCheckMarkRed;
            break;
            
        default:
            return [UIColor clearColor];
            break;
    }
}

@end
