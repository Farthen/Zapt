//
//  UIWindow+MainWindow.m
//  Zapr
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIWindow+MainWindow.h"

@implementation UIWindow (MainWindow)

+ (UIWindow *)mainWindow
{
    UIApplication *application = [UIApplication sharedApplication];
    id <UIApplicationDelegate> delegate = [application delegate];
    
    return delegate.window;
}

@end
