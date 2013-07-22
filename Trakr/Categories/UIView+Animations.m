#import "UIView+Animations.h"


#pragma mark Class Definition

@interface FAAnimation : NSObject
@property BOOL animate;
@property NSTimeInterval duration;
@property NSTimeInterval delay;
@property UIViewAnimationOptions options;
@property (copy) void (^setUp)(void);
@property (copy) void (^animations)(void);
@property (copy) void (^completion)(BOOL);

@property FAAnimation *next;
@end

@implementation FAAnimation
@end

@interface FAAnimationQueue : NSObject {
    FAAnimation *_nextAnimation;
}

+ (id)sharedInstance;
- (void)addAnimationWithAnimate:(BOOL)animate duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options setUp:(void (^)(void))setUp animations:(void (^)(void))animations completion:(void (^)(BOOL))completion;

@end

@implementation FAAnimationQueue

- (id)init
{
    self = [super init];
    if (self) {
        _nextAnimation = nil;
    }
    return self;
}

+ (id)sharedInstance
{
    static dispatch_once_t once;
    static FAAnimationQueue *object;
    dispatch_once(&once, ^ {
        object = [[FAAnimationQueue alloc] init];
    });
    return object;
}

- (void)addAnimation:(FAAnimation *)newAnimation
{
    BOOL executeNext = NO;
    @synchronized(self){
        if (_nextAnimation == nil) {
            _nextAnimation = newAnimation;
            executeNext = YES;
        } else {
            FAAnimation *animation = _nextAnimation;
            while (animation.next != nil) {
                animation = animation.next;
            }
            animation.next = newAnimation;
        }
    }
    if (executeNext) {
        [self executeNext];
    }
}

- (void)addAnimationWithAnimate:(BOOL)animate duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options setUp:(void (^)(void))setUp animations:(void (^)(void))animations completion:(void (^)(BOOL))completion;
{
    FAAnimation *animation = [[FAAnimation alloc] init];
    animation.animate = animate;
    animation.duration = duration;
    animation.delay = delay;
    animation.options = options;
    animation.setUp = setUp;
    animation.animations = animations;
    animation.completion = completion;
    [self addAnimation:animation];
}

- (void)finishAnimation
{
    BOOL newAnimation = NO;
    @synchronized(self){
        FAAnimation *next = _nextAnimation.next;
        _nextAnimation = next;
        // Check if there is another animation scheduled
        if (_nextAnimation) {
            newAnimation = YES;
        } // else we are running dry, no new yummy animations for us
    }
    if (newAnimation) {
        [self executeNext];
    }
}

- (void)executeNext
{
    FAAnimation *animation = _nextAnimation;
    if (animation != nil) {
        if (animation.setUp) {
            animation.setUp();
        }
        [UIView animateIf:animation.animate duration:animation.duration delay:animation.delay options:animation.options animations:animation.animations completion:^(BOOL finished){
            if (animation.completion) {
                animation.completion(finished);
            }
            // We are done now
            [self finishAnimation];
        }];
    }
}

@end

@implementation UIView (Animations)


#pragma mark -
#pragma mark Public Methods

+ (void)animateSynchronizedIf:(BOOL)condition duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options setUp:(void (^)(void))setUp animations:(void (^)(void))animations completion:(void (^)(BOOL))completion
{
    FAAnimationQueue *queue = [FAAnimationQueue sharedInstance];
    [queue addAnimationWithAnimate:condition duration:duration delay:delay options:options setUp:setUp animations:animations completion:completion];
}

+ (void)animateIf:(BOOL)condition duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion
{
    if (condition == YES)
	{
		[UIView animateWithDuration: duration
                              delay: delay
                            options: options
                         animations: animations
                         completion: completion];
	}
	else
	{
        // This is better than setting the duration of the animation to 0.0 because that will still result in the completion block being executed in a subsequent run loop.
		if (animations != nil)
		{
			animations();
		}
		
		if (completion != nil)
		{
			completion(YES);
		}
	}
}

+ (void)animateIf:(BOOL)condition duration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    [self animateIf:condition duration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionTransitionNone animations:animations completion:completion];
}

+ (void)animateSynchronizedIf:(BOOL)condition duration:(NSTimeInterval)duration setUp:(void (^)(void))setUp animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    [self animateSynchronizedIf:condition duration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionTransitionNone setUp:setUp animations:animations completion:completion];
}

+ (void)animateIf:(BOOL)condition duration:(NSTimeInterval)duration animations:(void (^)(void))animations
{
    [self animateIf:condition duration:duration animations:animations completion:nil];
}

@end // @implementation UIView (Animations)