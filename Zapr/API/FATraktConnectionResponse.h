//
//  FATraktConnectionError.h
//  Zapr
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LRResty/LRResty.h>

typedef enum {
    FATraktConnectionResponseTypeUnknown = -2,
    FATraktConnectionResponseTypeSuccess = -1,
    FATraktConnectionResponseTypeInvalidCredentials = 1,
    FATraktConnectionResponseTypeNetworkUnavailable = 2,
    FATraktConnectionResponseTypeServiceUnavailable = 3,
    FATraktConnectionResponseTypeTimeout = 4,
    FATraktConnectionResponseTypeNoData = 5,
    FATraktConnectionResponseTypeCancelled = 6,
    FATraktConnectionResponseTypeInvalidRequest = 7,
    
    FATraktConnectionResponseTypeAnyError = FATraktConnectionResponseTypeInvalidCredentials | FATraktConnectionResponseTypeNetworkUnavailable | FATraktConnectionResponseTypeServiceUnavailable | FATraktConnectionResponseTypeTimeout | FATraktConnectionResponseTypeNoData | FATraktConnectionResponseTypeInvalidRequest
} FATraktConnectionResponseType;

@interface FATraktConnectionResponse : NSObject

- (instancetype)initWithResponseType:(FATraktConnectionResponseType)responseType;

+ (instancetype)connectionResponseWithResponse:(LRRestyResponse *)response;

// Guaranteed to be unique
+ (instancetype)invalidRequestResponse;
+ (instancetype)invalidCredentialsResponse;

@property (readonly) LRRestyResponse *response;
@property FATraktConnectionResponseType responseType;

@end
