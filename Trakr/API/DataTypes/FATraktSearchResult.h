//
//  FATraktSearchResult.h
//  Trakr
//
//  Created by Finn Wilke on 22.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FATraktContent.h"

@interface FATraktSearchResult : FATraktDatatype <FACacheableItem>

- (id)initWithQuery:(NSString *)query contentType:(FATraktContentType)contentType;

@property (retain) NSArray *results;
@property (assign) FATraktContentType contentType;
@property (retain) NSString *query;

@end
