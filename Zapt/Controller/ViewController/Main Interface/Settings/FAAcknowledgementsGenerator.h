//
//  FAAcknowledgementsGenerator.h
//  Zapt
//
//  Created by Finn Wilke on 25/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAAcknowledgementsGenerator : NSObject

+ (NSMutableArray *)additionalAcknowledgements;
+ (NSArray *)allAcknowledgementsWithPodAcknowledgements:(NSArray *)podAcknowledgements;

@end
