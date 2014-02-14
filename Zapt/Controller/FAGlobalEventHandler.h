//
//  FAGlobalEventHandler.h
//  Zapt
//
//  Created by Finn Wilke on 02.10.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FATraktConnectionResponse;

@interface FAGlobalEventHandler : NSObject

+ (instancetype)handler;

@property BOOL authViewShowing;

- (void)handleApplicationLaunch;
- (void)handleApplicationResume;

- (void)showNeedsLoginAlertWithActionName:(NSString *)actionName;
- (void)performLoginAnimated:(BOOL)animated showInvalidCredentialsPrompt:(BOOL)showInvalidCredentialsPrompt completion:(void (^)(void))completion;
- (void)performLoginAnimated:(BOOL)animated showInvalidCredentialsPrompt:(BOOL)showInvalidCredentialsPrompt;
- (void)handleConnectionErrorResponse:(FATraktConnectionResponse *)response;
- (void)handleTimeout;
- (void)handleInvalidCredentials;

- (void)performRegisterAccount;

@end
