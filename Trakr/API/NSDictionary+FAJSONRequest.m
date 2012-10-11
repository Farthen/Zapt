//
//  NSDictionary+FAJSONRequest.m
//  
//
//  Created by Finn Wilke on 10.09.12.
//
//

#import "NSDictionary+FAJSONRequest.h"
#import <LRResty.h>
#import <JSONKit.h>

@implementation NSDictionary (FAJSONRequest)

- (void)modifyRequest:(LRRestyRequest *)request
{
    [request setPostData:[[self JSONString] dataUsingEncoding:NSUTF8StringEncoding]];
    [request addHeader:@"Content-Type" value:@"application/json"];
}

@end
