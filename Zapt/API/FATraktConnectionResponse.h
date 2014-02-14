//
//  FATraktConnectionError.h
//  Zapt
//
//  Created by Finn Wilke on 07.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

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
    
    FATraktConnectionResponseTypeAnyError = FATraktConnectionResponseTypeInvalidCredentials | FATraktConnectionResponseTypeNetworkUnavailable | FATraktConnectionResponseTypeServiceUnavailable | FATraktConnectionResponseTypeTimeout | FATraktConnectionResponseTypeNoData | FATraktConnectionResponseTypeInvalidRequest | FATraktConnectionResponseTypeInvalidData,
    
    FATraktConnectionResponseTypeResourceError = FATraktConnectionResponseTypeNetworkUnavailable | FATraktConnectionResponseTypeServiceUnavailable
} FATraktConnectionResponseType;

@interface FATraktConnectionResponse : NSObject

- (instancetype)initWithResponseType:(FATraktConnectionResponseType)responseType;

+ (instancetype)connectionResponseWithHTTPResponse:(NSHTTPURLResponse *)response;
+ (instancetype)connectionResponseWithHTTPResponse:(NSHTTPURLResponse *)response responseData:(NSDictionary *)responseData;

// Guaranteed to be unique
+ (instancetype)invalidRequestResponse;
+ (instancetype)invalidCredentialsResponse;
+ (instancetype)invalidDataResponse;

- (void)setResponseData:(id)data;

@property (readonly) NSHTTPURLResponse *response;
@property FATraktConnectionResponseType responseType;

@property (readonly) UIImage *imageData;
@property (readonly) id jsonData;

@end
