//
//  FAMaskingView.m
//  Zapr
//
//  Created by Finn Wilke on 25.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAMaskingView.h"

@implementation FAMaskingView {
    NSMutableArray *_maskingLayers;
    CAShapeLayer *_maskLayer;
    CALayer *_backingLayer;
    
    NSMapTable *_overrideRects;
    
    CADisplayLink *_displayLink;
}

- (void)setup
{
    _maskingLayers = [[NSMutableArray alloc] init];
    _overrideRects = [[NSMapTable alloc] init];
    
    _backingLayer = [[CALayer alloc] init];
    _backingLayer.frame = self.layer.bounds;
    [self.layer addSublayer:_backingLayer];
    
    _maskLayer.frame = self.layer.bounds;
    _maskLayer.contentsScale = [[UIScreen mainScreen] scale];
    _maskLayer = [[CAShapeLayer alloc] init];
    _maskLayer.backgroundColor = [[UIColor blackColor] CGColor];
    _backingLayer.mask = _maskLayer;
    
    _backingLayer.backgroundColor = [[UIColor blackColor] CGColor];
    //_maskLayer.geometryFlipped = YES;
    //_maskLayer.drawsAsynchronously = YES;
}

- (void)setMaskedImage:(UIImage *)image
{
    _backingLayer.backgroundColor = [[UIColor clearColor] CGColor];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [_backingLayer addAnimation:transition forKey:@"contents"];
    
    _backingLayer.contents = (__bridge id)(image.CGImage);

}

- (void)updateContinuouslyFor:(NSTimeInterval)seconds
{
    [self updateContinuously];
    NSTimer *stopTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(stopUpdatingContinuously) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:stopTimer forMode:NSRunLoopCommonModes];
}

- (void)updateContinuously
{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopUpdatingContinuously
{
    [_displayLink invalidate];
    _displayLink = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self update];
}


- (void)addMaskLayer:(CALayer *)layer
{
    @synchronized(self) {
        [_maskingLayers addObject:layer];
    }
}

- (void)removeMaskLayer:(CALayer *)layer
{
    @synchronized(self) {
        [_maskingLayers removeObject:layer];
    }
}

- (void)setOverrideRect:(CGRect)rect forLayer:(CALayer *)layer
{
    // This will set a different rect that is not the current rect of the layer
    // Remember to call the removal function afterwards
    if ([_maskingLayers containsObject:layer]) {
        [_overrideRects setObject:[NSValue valueWithCGRect:rect] forKey:layer];
    }
}

- (void)removeOverrideRectForLayer:(CALayer *)layer
{
    [_overrideRects removeObjectForKey:layer];
}

- (void)update
{
    
    // Start a new transaction, the whole thing will be committed at the end
    [CATransaction begin];
    
    // Create a new CGMutablePath. Remember to release it afterwards
    CGMutablePathRef path = CGPathCreateMutable();
    
    // Iterate over the layers and add the layer frames to the CGPath
    for (CALayer *maskingLayer in _maskingLayers) {
        // Convert to the right coordinate system
        CGRect rect;
        NSValue *overrideRectValue = [_overrideRects objectForKey:maskingLayer];
        if (overrideRectValue != nil) {
            rect = [overrideRectValue CGRectValue];
        } else {
            rect = [_maskLayer convertRect:[maskingLayer bounds] fromLayer:maskingLayer];
        }
        
        // Hack because the presentationlayer is actually laggy so we don't want to use it when possible
        //if (_displayLink) {
        //    rect = [_maskLayer convertRect:[maskingLayer bounds] fromLayer:maskingLayer.presentationLayer];
        //} else {
        //    rect = [_maskLayer convertRect:[maskingLayer.presentationLayer bounds] fromLayer:maskingLayer];
        //}
        
        // Convert a 0,0 Point to the masking layer. Then we know the current offset.
        //CGPoint offsetPoint = [maskingLayer convertPoint:CGPointMake(0, 0) fromLayer:[maskingLayer presentationLayer]];
        
        //CGRect presentationLayerRect = [[maskingLayer presentationLayer] frame];
        
        // Apply the offset
        //rect.origin.x -= offsetPoint.x;
        //rect.origin.y -= offsetPoint.y;
        
        //rect = [_maskLayer.presentationLayer convertRect:[[maskingLayer presentationLayer] bounds] fromLayer:maskingLayer.presentationLayer];
        //rect = [_maskLayer convertRect:[maskingLayer bounds] fromLayer:maskingLayer];
        
        // Add it to the path
        CGPathAddRect(path, NULL, rect);
    }
    
    _maskLayer.path = path;
    
    // Release the path
    CGPathRelease(path);
    
    // End the current transaction
    [CATransaction commit];
}

@end
