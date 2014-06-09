//
//  FAConnectionDelegate.h
//  Zapt
//
//  Created by Finn Wilke on 08/06/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import <Foundation/Foundation.h>
@import FATrakt;

@interface FAConnectionDelegate : NSObject <FATraktConnectionDelegate>

- (instancetype)initWithConnection:(FATraktConnection *)connection;

@end
