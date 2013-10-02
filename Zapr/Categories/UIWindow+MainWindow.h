//
//  UIWindow+MainWindow.h
//  Zapr
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (MainWindow)

// Returns the main window of the application
// This is the window that was created by the application delegate
+ (UIWindow *)mainWindow;

@end
