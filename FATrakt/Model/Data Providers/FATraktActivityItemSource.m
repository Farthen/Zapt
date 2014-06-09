//
//  FATraktActivityItemSource.m
//  Zapt
//
//  Created by Finn Wilke on 26.09.13.
//  Copyright (c) 2013 Finn Wilke. All rights reserved.
//

#import "FATraktActivityItemSource.h"
#import <FATrakt/FATrakt.h>

@interface FATraktActivityItemSource ()
@property FATraktContent *content;
@property Class type;
@end

@implementation FATraktActivityItemSource

- (instancetype)initWithContent:(FATraktContent *)content type:(Class)type
{
    self = [super init];
    
    if (self) {
        self.content = content;
        self.type = type;
    }
    
    return self;
}

+ (NSArray *)activityItemSourcesWithContent:(FATraktContent *)content
{
    return @[[[FATraktActivityItemSource alloc] initWithContent:content type:[NSString class]],
             [[FATraktActivityItemSource alloc] initWithContent:content type:[NSURL class]]];
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    if (self.type == [NSString class]) {
        return @"";
    } else if (self.type == [NSURL class]) {
        return [NSURL URLWithString:@"http://trakt.tv/"];
    }
    
    return nil;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    if (activityType == UIActivityTypeMail) {
        return [NSString stringWithFormat:NSLocalizedString(@"Check out %@ on Trakt!", nil), self.content.title];
    }
    
    return nil;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    NSString *itemTypeString = [FAInterfaceStringProvider nameForContentType:self.content.contentType withPlural:NO capitalized:YES longVersion:YES];
    NSString *itemTypeShortName = [FAInterfaceStringProvider nameForContentType:self.content.contentType withPlural:NO capitalized:NO longVersion:NO];
    NSString *itemName = self.content.title;
    NSString *itemURL = self.content.url;
    
    if (self.type == [NSString class]) {
        if (activityType == UIActivityTypePostToTwitter) {
            return [NSString stringWithFormat:NSLocalizedString(@"Check out \"%@\" on Trakt! #%@ #Zapt", nil), itemName, itemTypeShortName];
        } else if (activityType == UIActivityTypePostToTencentWeibo) {
            return [NSString stringWithFormat:NSLocalizedString(@"Check out \"%@\" on Trakt! #%@# #Zapt#", nil), itemName, itemTypeShortName];
        } else if (activityType == UIActivityTypeMessage ||
                   activityType == UIActivityTypePostToFacebook) {
            return [NSString stringWithFormat:NSLocalizedString(@"Check out \"%@\" on Trakt! %@", nil), itemName, itemTypeShortName];
        } else if (activityType == UIActivityTypeMail) {
            // FIXME URL
            return [NSString stringWithFormat:NSLocalizedString(@"\
                                                                <html>\
                                                                <body>\
                                                                <p>Hey there!</p>\
                                                                <p>I've found this %@ on Trakt: <a href=\"%@\">%@</a> and thought you might want to check it out.</p>\
                                                                <p>Have a nice day!</p>\
                                                                <p><small style=\"font-size:10px;\">Sent with <a href=\"http://zapt.farthen.de\" style=\"font-size:10px;\">Zapt</a>, an iPhone App to manage your favorite movies and TV Shows in your <a href=\"http://trakt.tv\" style=\"font-size:10px;\">Trakt</a> library</small></p>\
                                                                </body></html>\
                                                                ", nil), itemTypeString, itemURL, itemName];
        }
    } else if (self.type == [NSURL class]) {
        return [NSURL URLWithString:itemURL];
    }
    
    return nil;
}

@end
