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
    FATraktConnectionResponseTypeUnknown = (1 << 0),
    FATraktConnectionResponseTypeSuccess = (1 << 1),
    FATraktConnectionResponseTypeInvalidCredentials = (1 << 2),
    FATraktConnectionResponseTypeNetworkUnavailable = (1 << 3),
    FATraktConnectionResponseTypeServiceUnavailable = (1 << 4),
    FATraktConnectionResponseTypeTimeout = (1 << 5),
    FATraktConnectionResponseTypeNoData = (1 << 6),
    FATraktConnectionResponseTypeCancelled = (1 << 7),
    FATraktConnectionResponseTypeInvalidRequest = (1 << 8),
    FATraktConnectionResponseTypeInvalidData = (1 << 9),
    
    FATraktConnectionResponseTypeAnyError = FATraktConnectionResponseTypeInvalidCredentials | FATraktConnectionResponseTypeNetworkUnavailable | FATraktConnectionResponseTypeServiceUnavailable | FATraktConnectionResponseTypeTimeout | FATraktConnectionResponseTypeNoData | FATraktConnectionResponseTypeInvalidRequest | FATraktConnectionResponseTypeInvalidData
} FATraktConnectionResponseType;

@interface FATraktConnectionResponse : NSObject

- (instancetype)initWithResponseType:(FATraktConnectionResponseType)responseType;

+ (instancetype)connectionResponseWithResponse:(LRRestyResponse *)response;

// Guaranteed to be unique
+ (instancetype)invalidRequestResponse;
+ (instancetype)invalidCredentialsResponse;
+ (instancetype)invalidDataResponse;

@property (readonly) LRRestyResponse *response;
@property FATraktConnectionResponseType responseType;

@end
