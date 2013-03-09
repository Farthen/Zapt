//
//  FAContentPrefsView.m
//  Trakr
//
//  Created by Finn Wilke on 08.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FAContentPrefsView.h"

@implementation FAContentPrefsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.backgroundColor = [UIColor redColor];
}


- (void)displayContent:(FATraktContent *)content
{
    
}

@end
