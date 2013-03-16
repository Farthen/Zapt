//
//  FASegmentedControl.m
//  Trakr
//
//  Created by Finn Wilke on 16.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FASegmentedControl.h"

@implementation FASegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    int oldValue = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
    if (oldValue == self.selectedSegmentIndex) {
        if (self.allowDeselection) {
            self.selectedSegmentIndex = UISegmentedControlNoSegment;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

@end
