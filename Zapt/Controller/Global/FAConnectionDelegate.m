//
//  FAConnectionDelegate.m
//  Zapt
//
//  Created by Finn Wilke on 08/06/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FAConnectionDelegate.h"
#import "FAGlobalEventHandler.h"
#import "FAActivityDispatch.h"
#import "FAStatusBarSpinnerController.h"

@interface FAConnectionDelegate ()
@property (nonatomic) FAActivityDispatch *activityDispatch;
@end

@implementation FAConnectionDelegate

- (instancetype)initWithConnection:(FATraktConnection *)connection
{
    self = [super init];
    if (self) {
        connection.delegate = self;
        
        self.activityDispatch = [FAActivityDispatch sharedInstance];
        [self.activityDispatch registerForAllActivity:[FAStatusBarSpinnerController sharedInstance]];
    }
    
    return self;
}

// Last possibility for the delegate to cancel a request
- (BOOL)traktConnection:(FATraktConnection *)connection shouldSendRequest:(FATraktRequest *)request
{
    return YES;
}

// Gets called directly after a request is dispatched
- (void)traktConnection:(FATraktConnection *)connection didSendRequest:(FATraktRequest *)request
{
    [self.activityDispatch startActivityNamed:request.activityName];
}

// Gets called when a request returns valid data
- (void)traktConnection:(FATraktConnection *)connection request:(FATraktRequest *)request succeededWithResponse:(FATraktConnectionResponse *)response
{
    [self.activityDispatch finishActivityNamed:request.activityName];
}

// Gets called when a request fails
- (void)traktConnection:(FATraktConnection *)connection request:(FATraktRequest *)request failedWithResponse:(FATraktConnectionResponse *)response
{
    [self.activityDispatch finishActivityNamed:request.activityName];
}

// Gets called when the credentials are invalid
- (void)traktConnectionHandleInvalidCredentials:(FATraktConnection *)connection
{
    [[FAGlobalEventHandler handler] handleInvalidCredentials];
}

// Gets called when a request failed and there isn't any specific error callback
- (void)traktConnection:(FATraktConnection *)connection handleUnhandledErrorResponse:(FATraktConnectionResponse *)response
{
    [[FAGlobalEventHandler handler] handleConnectionErrorResponse:response];
}

@end
