//
//  FATraktList.h
//  Zapt
//
//  Created by Finn Wilke on 24.02.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"
#import "FACacheableItem.h"
#import "FATraktContent.h"

@interface FATraktList : FATraktCachedDatatype

typedef NS_ENUM(NSUInteger, FATraktListPrivacy) {
    FATraktListPrivacyPrivate,
    FATraktListPrivacyFriends,
    FATraktListPrivacyPublic
};

+ (FATraktList *)cachedListForWatchlistWithContentType:(FATraktContentType)contentType;
+ (FATraktList *)cachedListForLibraryWithContentType:(FATraktContentType)contentType libraryType:(FATraktLibraryType)libraryType;
+ (NSArray *)cachedCustomLists;

- (BOOL)containsContent:(FATraktContent *)content;
- (void)addContent:(FATraktContent *)content;
- (void)removeContent:(FATraktContent *)content;

@property (retain) NSString *name;
@property (retain) NSString *slug;
@property (retain) NSString *url;
@property (retain) NSString *list_description;
@property (assign) FATraktListPrivacy privacy;
@property (assign) BOOL show_numbers;
@property (assign) BOOL allow_shouts;
@property (retain) NSMutableArray *items;

@property (assign) BOOL isWatchlist;
@property (assign) BOOL isLibrary;
@property (assign) BOOL isCustom;

@property (assign) FATraktLibraryType libraryType;
@property (assign) FATraktContentType contentType;

@property (assign) FATraktDetailLevel detailLevel;
@end
