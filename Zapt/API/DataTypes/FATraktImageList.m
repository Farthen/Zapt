//
//  FATraktImages.m
//  Zapt
//
//  Created by Finn Wilke on 18.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktImageList.h"

@implementation FATraktImageList

- (NSString *)description
{
    NSMutableDictionary *images = [NSMutableDictionary dictionary];
    
    if (self.poster) {
        images[@"poster"] = self.poster;
    }
    
    if (self.fanart) {
        images[@"fanart"] = self.poster;
    }
    
    if (self.banner) {
        images[@"banner"] = self.poster;
    }
    
    if (self.screen) {
        images[@"screen"] = self.poster;
    }
    
    return [NSString stringWithFormat:@"<FATraktImageList %p with images: %@>", self, images.description];
}

@end
