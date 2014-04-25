#pragma mark Class Interface

@interface UIView (Animations)


#pragma mark -
#pragma mark Static Methods

// Normal animation functions
+ (void)animateIf:(BOOL)condition duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL))completion;
+ (void)animateIf:(BOOL)condition duration:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animateIf:(BOOL)condition duration:(NSTimeInterval)duration animations:(void (^)(void))animations;

// Synchronized animation functions
+ (void)animateSynchronizedIf:(BOOL)condition duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options setUp:(void (^)(void))setUp animations:(void (^)(void))animations completion:(void (^)(BOOL))completion;
+ (void)animateSynchronizedIf:(BOOL)condition duration:(NSTimeInterval)duration setUp:(void (^)(void))setUp animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

@end // @interface UIView (Animations)
