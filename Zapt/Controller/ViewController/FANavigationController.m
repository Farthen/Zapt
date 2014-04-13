//
//  FANavigationController.m
//  Zapt
//
//  Created by Finn Wilke on 22.07.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FANavigationController.h"

@interface FANavigationController () {
    UILongPressGestureRecognizer *_longPressGesture;
}

@property (nonatomic) NSDictionary *nextTransitionInformation;

@end

NSString *const FANavigationControllerDidPopToRootViewControllerNotification = @"FATraktActivityNotificationSearch";

@implementation FANavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;

    [self addLongButtonTouchGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// stolen from http://stackoverflow.com/a/10005594/1084385
- (void)longPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        // set a default rectangle in case we don't find the back button for some reason
        CGRect rect = CGRectMake(0, 0, 100, 40);
        
        UINavigationBar *navBar = [self navigationBar];
        rect.size.height = navBar.bounds.size.height;
        
        // ok, let's get the point of the long press
        CGPoint longPressPoint = [sender locationInView:self.navigationBar];
        
        // if the long press point in the rectangle then do whatever
        if (CGRectContainsPoint(rect, longPressPoint)) {
            BOOL pop = YES;
            
            // Check if the delegate wants to have a say in this
            id <FANavigationControllerLongButtonTouchDelegate> __weak delegate = (id <FANavigationControllerLongButtonTouchDelegate> )self.delegate;
            UIViewController *lastViewController = self.viewControllers.lastObject;
            
            if ([self.delegate conformsToProtocol:@protocol(FANavigationControllerLongButtonTouchDelegate)]) {
                if ([delegate respondsToSelector:@selector(navigationController:shouldPopToRootViewControllerAfterLongButtonTouchForViewController:)]) {
                    pop = [delegate navigationController:self shouldPopToRootViewControllerAfterLongButtonTouchForViewController:lastViewController];
                }
            }
            
            if (pop) {
                [self popToRootViewControllerAnimated:YES];
                
                if ([delegate respondsToSelector:@selector(navigationController:didPopToRootViewControllerAfterLongButtonTouchForViewController:)]) {
                    [delegate navigationController:self didPopToRootViewControllerAfterLongButtonTouchForViewController:lastViewController];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:FANavigationControllerDidPopToRootViewControllerNotification object:self];
            }
        }
    }
}

- (void)addLongButtonTouchGesture
{
    if (NSClassFromString(@"UILongPressGestureRecognizer")) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        _longPressGesture.minimumPressDuration = 0.7;
        [self.navigationBar addGestureRecognizer:_longPressGesture];
    }
}

- (void)removeLongButtonTouchGesture
{
    if (_longPressGesture) {
        [self.navigationBar removeGestureRecognizer:_longPressGesture];
        _longPressGesture = nil;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.nextTransitionInformation = nil;
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    self.nextTransitionInformation = nil;
    return [super popViewControllerAnimated:animated];
}

- (void)replaceTopViewControllerWithViewController:(UIViewController *)newViewController usingSlideAnimation:(BOOL)animated direction:(FASlideAnimatedTransitionDirection)direction completion:(void (^)(void))completion
{
    NSMutableArray *viewControllers = [[self viewControllers] mutableCopy];
    NSUInteger lastVCIndex = [viewControllers count] - 1;
    if (lastVCIndex > 0) {
        UIViewController *oldViewController = [viewControllers objectAtIndex:lastVCIndex];
        [viewControllers replaceObjectAtIndex:lastVCIndex withObject:newViewController];
        
        if (animated) {
            NSMutableDictionary *transitionInformation = [NSMutableDictionary dictionary];
            [transitionInformation setObject:oldViewController forKey:@"fromViewController"];
            [transitionInformation setObject:newViewController forKey:@"toViewController"];
            [transitionInformation setObject:@"slide" forKey:@"animationType"];
            [transitionInformation setObject:[NSNumber numberWithInteger:direction] forKey:@"directionUp"];
            self.nextTransitionInformation = transitionInformation;
        }
        
        [self setViewControllers:viewControllers animated:YES];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (self.nextTransitionInformation) {
        if (self.nextTransitionInformation[@"fromViewController"] == fromVC &&
            self.nextTransitionInformation[@"toViewController"] == toVC) {
            if ([self.nextTransitionInformation[@"animationType"] isEqualToString:@"slide"]) {
                FASlideAnimatedTransition *transition = [[FASlideAnimatedTransition alloc] init];
                
                FASlideAnimatedTransitionDirection direction = [self.nextTransitionInformation[@"directionUp"] integerValue];
                
                if (direction == FASlideAnimatedTransitionDirectionDown) {
                    transition.direction = FASlideAnimatedTransitionDirectionDown;
                } else {
                    transition.direction = FASlideAnimatedTransitionDirectionUp;
                }
                
                return transition;
            }
        }
    }
    
    return nil;
}

- (void)dealloc
{
    [self removeLongButtonTouchGesture];
}

@end
