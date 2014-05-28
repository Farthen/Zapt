//
//  FAAcknowledgementsGenerator.m
//  Zapt
//
//  Created by Finn Wilke on 25/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FAAcknowledgementsGenerator.h"
#import <VTAcknowledgementsViewController/VTAcknowledgement.h>

@implementation FAAcknowledgementsGenerator

+ (NSMutableArray *)additionalAcknowledgements
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AdditionalAcknowledgements" ofType:@"plist"];
    NSArray *items = [NSArray arrayWithContentsOfFile:path];
    
    NSMutableArray *acknowledgements = [items mapUsingBlock:^id(NSDictionary *dict, NSUInteger idx) {
        VTAcknowledgement *acknowledgement = [[VTAcknowledgement alloc] init];
        acknowledgement.title = dict[@"title"];
        acknowledgement.text = dict[@"text"];
        
        return acknowledgement;
    }];
    
    return acknowledgements;
}

+ (NSArray *)allAcknowledgementsWithPodAcknowledgements:(NSArray *)podAcknowledgements
{
    NSMutableArray *acknowledgements = [self additionalAcknowledgements];
    [acknowledgements addObjectsFromArray:podAcknowledgements];
    
    [acknowledgements sortUsingComparator:^NSComparisonResult(VTAcknowledgement *obj1, VTAcknowledgement *obj2) {
        return [obj1.title compare:obj2.title
                           options:kNilOptions
                             range:NSMakeRange(0, obj1.title.length)
                            locale:[NSLocale currentLocale]];
    }];
    
    return acknowledgements;
}

@end
