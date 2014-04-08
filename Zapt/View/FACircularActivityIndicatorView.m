//
//  FACircularActivityIndicatorView.m
//  Zapt
//
//  Created by Finn Wilke on 09/03/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FACircularActivityIndicatorView.h"

typedef NS_ENUM(NSInteger, FACircularActivityIndicatorStatus) {
    FACircularActivityIndicatorStatusStopped = 0,
    FACircularActivityIndicatorStatusStarting,
    FACircularActivityIndicatorStatusSpinning,
    FACircularActivityIndicatorStatusStopping
};

@interface FACircularActivityIndicatorView ()
@property (nonatomic) CGFloat circleRadian;
@property (nonatomic) CAShapeLayer *animationShapeLayer;

@property (nonatomic) CABasicAnimation *progressAnimation;

@property (nonatomic) NSInteger animationCount;

@property (nonatomic) FACircularActivityIndicatorStatus animationStatus;
@end

@implementation FACircularActivityIndicatorView {
    CGFloat _circleRadian;
    FACircularActivityIndicatorStatus _animationStatus;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor whiteColor];
        self.animationShapeLayer = [[CAShapeLayer alloc] init];
        self.animationShapeLayer.frame = self.layer.bounds;
        self.animationShapeLayer.strokeColor = [[UIColor blueColor] CGColor];
        self.animationShapeLayer.fillColor = nil;
        self.animationShapeLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        [self.layer addSublayer:self.animationShapeLayer];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (CGRect)circleRect
{
    CGFloat inset = 4;
    return CGRectInset(self.bounds, inset, inset);
}

- (CGFloat)circleRadius
{
    return self.circleRect.size.width / 2;
}

- (CGFloat)circleClosedFraction
{
    return 0.9;
}

- (CGFloat)startAnimationDuration
{
    return 1.5;
}

- (CGFloat)rotationDuration
{
    return 1.5;
}

- (void)startAnimating
{
    CABasicAnimation *startAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    startAnimation.delegate = self;
    startAnimation.removedOnCompletion = NO;
    
    [startAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:self.circleRadius startAngle:0 endAngle:[self circleClosedFraction] * 2 * M_PI clockwise:YES];
    self.animationShapeLayer.path = [endPath CGPath];
    self.animationShapeLayer.lineWidth = 5;
    
    self.animationShapeLayer.strokeStart = 0;
    self.animationShapeLayer.strokeEnd = 1;
    
    startAnimation.fromValue = @0;
    startAnimation.toValue = @1;
    
    startAnimation.duration = [self startAnimationDuration];
    
    self.animationStatus = FACircularActivityIndicatorStatusStarting;
    [self.animationShapeLayer addAnimation:startAnimation forKey:@"startAnimation"];
    
    [self performSelector:@selector(stopAnimating) withObject:self afterDelay:10];
}

- (void)stopAnimating
{
    CABasicAnimation *stopAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    stopAnimation.delegate = self;
    stopAnimation.removedOnCompletion = NO;
    
    [stopAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:self.circleRadius startAngle:0 endAngle:[self circleClosedFraction] * 2 * M_PI clockwise:YES];
    self.animationShapeLayer.path = [endPath CGPath];
    self.animationShapeLayer.lineWidth = 5;
    
    self.animationShapeLayer.strokeStart = 0;
    self.animationShapeLayer.strokeEnd = 1;
    
    stopAnimation.fromValue = @0;
    stopAnimation.toValue = @1;
    
    stopAnimation.duration = [self startAnimationDuration];
    
    self.animationStatus = FACircularActivityIndicatorStatusStopping;
    [self.animationShapeLayer addAnimation:stopAnimation forKey:@"stopAnimation"];
}

- (void)animationDidStart:(CAAnimation *)animation
{
    if (animation == [self.animationShapeLayer animationForKey:@"startAnimation"]) {
        CGFloat rotationAngle = 2 * M_PI;
        
        CATransform3D myRotationTransform = CATransform3DRotate(self.animationShapeLayer.transform, rotationAngle, 0.0, 0.0, 1.0);
        self.animationShapeLayer.transform = myRotationTransform;
        
        CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        progressAnimation.delegate = self;
        progressAnimation.removedOnCompletion = YES;
        [progressAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        
        progressAnimation.duration = [self rotationDuration];
        progressAnimation.repeatCount = HUGE_VALF;
        progressAnimation.fromValue = 0;
        progressAnimation.toValue = [NSNumber numberWithFloat:(rotationAngle)];
        [self.animationShapeLayer addAnimation:progressAnimation forKey:@"progressAnimation"];
        
        self.progressAnimation = progressAnimation;
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag;
{
    if (animation == [self.animationShapeLayer animationForKey:@"startAnimation"]) {
        [self.animationShapeLayer removeAnimationForKey:@"startAnimation"];
        
        if (self.animationStatus == FACircularActivityIndicatorStatusStarting) {
            self.animationStatus = FACircularActivityIndicatorStatusSpinning;
        }
        
    } else if (animation == [self.animationShapeLayer animationForKey:@"stopAnimation"]) {
        [self.animationShapeLayer removeAnimationForKey:@"stopAnimation"];
        [self.animationShapeLayer removeAnimationForKey:@"progressAnimation"];
        self.animationStatus = FACircularActivityIndicatorStatusStopped;
        
        // reset the environment
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.animationShapeLayer.strokeStart = 0;
        self.animationShapeLayer.strokeEnd = 0;
        [CATransaction commit];
    }
}

- (FACircularActivityIndicatorStatus)animationStatus
{
    return _animationStatus;
}

- (void)setAnimationStatus:(FACircularActivityIndicatorStatus)animationStatus
{
    _animationStatus = animationStatus;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    if (self.circleRadian > 0) {
    }
}


@end
