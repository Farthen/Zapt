//
//  FATraktDatatype.h
//  Trakr
//
//  Created by Finn Wilke on 11.10.12.
//  Copyright (c) 2012 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FATraktDatatype : NSObject {
    NSDictionary *_originDict;
}

- (id)initWithJSONDict:(NSDictionary *)dict;
- (void)mapObjectsInDict:(NSDictionary *)dict;
- (void)mapObject:(id)object ofType:(NSString *)propertyType toPropertyWithKey:(NSString *)key;
- (void)mapObject:(id)object toPropertyWithKey:(NSString *)key;

@end
