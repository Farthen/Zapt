//
//  FATraktPeopleList.h
//  Zapr
//
//  Created by Finn Wilke on 12.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import "FATraktDatatype.h"

@interface FATraktPeopleList : FATraktDatatype

@property (retain) NSArray *directors;
@property (retain) NSArray *writers;
@property (retain) NSArray *producers;
@property (retain) NSArray *actors;

@end
