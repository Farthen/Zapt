//
//  FATraktSearchResult.h
//  Zapr
//
//  Created by Finn Wilke on 22.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FATraktContent.h"

@interface FATraktSearchResult : FATraktCachedDatatype <FACacheableItem>

- (id)initWithQuery:(NSString *)query contentType:(FATraktContentType)contentType;

@property (retain) NSArray *results;
@property NSArray *resultCacheKeys;

@property (assign) FATraktContentType contentType;
@property (retain) NSString *query;

@end
