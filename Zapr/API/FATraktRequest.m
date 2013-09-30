//
//  FATraktRequest.m
//  Zapr
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktRequest.h"
#import "FAActivityDispatch.h"

@interface FATraktRequest ()
@property NSString *activityName;
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
    [self.restyRequest cancelImmediately];
    [self finishActivity];
}

- (void)startActivity
{
    [[FAActivityDispatch sharedInstance] startActivityNamed:self.activityName];
}

- (void)finishActivity
{
    [[FAActivityDispatch sharedInstance] finishActivityNamed:self.activityName];
}

@end
