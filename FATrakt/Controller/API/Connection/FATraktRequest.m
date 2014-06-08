//
//  FATraktRequest.m
//  Zapt
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktRequest.h"

@interface FATraktRequest ()
@property NSString *activityName;
@property (nonatomic) BOOL isCancelled;
@property (nonatomic) BOOL isInvalidated;
@property (nonatomic) BOOL isFinished;
@end

@implementation FATraktRequest

+ (instancetype)requestWithActivityName:(NSString *)activityName
{
    FATraktRequest *request = [[self alloc] init];
    
    if (request) {
        request.activityName = activityName;
    }
    
    return request;
}

- (void)cancelImmediately
{
    [self.operation cancel];
    
    self.isCancelled = YES;
}

- (void)invalidate
{
    self.isInvalidated = YES;
}

- (FATraktRequestState)requestState
{
    if (self.isCancelled) {
        return FATraktRequestStateCancelled;
    }
    
    if (self.isInvalidated) {
        return FATraktRequestStateInvalid;
    }
    
    if (self.operation.isExecuting) {
        return FATraktRequestStateExecuting;
    }
    
    if (self.operation.isFinished) {
        return FATraktRequestStateFinished;
    }
    
    return FATraktRequestStateUnknown;
}

@end
