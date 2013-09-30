//
//  FATraktRequest.h
//  Zapr
//
//  Created by Finn Wilke on 30.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LRResty/LRResty.h>

@interface FATraktRequest : NSObject

+ (instancetype)requestWithActivityName:(NSString *)activityName;

- (void)startActivity;
- (void)finishActivity;
- (void)cancelImmediately;

@property LRRestyRequest *restyRequest;
@property (readonly) NSString *activityName;

@end
