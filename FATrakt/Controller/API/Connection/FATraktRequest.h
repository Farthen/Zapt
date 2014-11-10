//
//  FATraktRequest.h
//  Zapt
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger, FATraktRequestState) {
    FATraktRequestStateExecuting = (1 << 0),
    
    FATraktRequestStateFinished = (1 << 1),
    FATraktRequestStateCancelled = (1 << 2),
    FATraktRequestStateInvalid = (1 << 2),
    
    FATraktRequestStateStopped = FATraktRequestStateFinished | FATraktRequestStateCancelled | FATraktRequestStateInvalid,
    
    FATraktRequestStateUnknown = (1 << 3),
};

@interface FATraktRequest : NSObject

+ (instancetype)requestWithActivityName:(NSString *)activityName;

- (void)cancelImmediately;
- (void)invalidate;

@property AFHTTPRequestOperation *operation;
@property (readonly) NSString *activityName;
@property (readonly) FATraktRequestState requestState;

@end
