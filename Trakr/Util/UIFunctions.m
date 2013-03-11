//
//  UIFunctions.m
//  Trakr
//
//  Created by Finn Wilke on 11.03.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "UIFunctions.h"

UIEdgeInsets UIEdgeInsetsAdd(UIEdgeInsets a, UIEdgeInsets b)
{
    UIEdgeInsets newEdgeInsets;
    newEdgeInsets.top = a.top + b.top;
    newEdgeInsets.left = a.left + b.left;
    newEdgeInsets.bottom = a.bottom + b.bottom;
    newEdgeInsets.right = a.right + b.right;
    return newEdgeInsets;
}

UIEdgeInsets UIEdgeInsetsSubtract(UIEdgeInsets a, UIEdgeInsets b)
{
    UIEdgeInsets newEdgeInsets;
    newEdgeInsets.top = a.top - b.top;
    newEdgeInsets.left = a.left - b.left;
    newEdgeInsets.bottom = a.bottom - b.bottom;
    newEdgeInsets.right = a.right - b.right;
    return newEdgeInsets;
}
