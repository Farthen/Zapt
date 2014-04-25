//
//  FATraktActivityItemSource.h
//  Zapt
//
//  Created by Finn Wilke on 26.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FATraktContent.h"

@interface FATraktActivityItemSource : NSObject <UIActivityItemSource>

+ (NSArray *)activityItemSourcesWithContent:(FATraktContent *)content;

@end
