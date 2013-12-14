//
//  UIStoryboard+MainStoryboard.m
//  Zapr
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIStoryboard+MainStoryboard.h"

@implementation UIStoryboard (MainStoryboard)

+ (UIStoryboard *)mainStoryboard
{
    id <UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *mainWindow = appDelegate.window;
    
    return mainWindow.rootViewController.storyboard;
}

@end
