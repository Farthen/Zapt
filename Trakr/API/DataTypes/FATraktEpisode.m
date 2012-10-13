//
//  FATraktEpisode.m
//  Trakr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktEpisode.h"

@implementation FATraktEpisode

- (id)initWithJSONDict:(NSDictionary *)dict andShow:(FATraktShow *)show
{
    self = [super initWithJSONDict:dict];
    if (self) {
        self.show = show;
    }
    return self;
}

@end
