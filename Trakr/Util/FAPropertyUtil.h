//
//  FAPropertyUtil.h
//  Trakr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAPropertyInfo.h"

@interface FAPropertyUtil : NSObject

+ (NSDictionary *)propertyInfoForClass:(Class)class;
@end
