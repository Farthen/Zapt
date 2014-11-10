//
//  FACalendarEventController.m
//  Zapt
//
//  Created by Finn Wilke on 25/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FACalendarEventController.h"
#import "FCActionSheet.h"
#import "FCAlertView.h"

#import "FAInterfaceStringProvider.h"
#import <EventKitUI/EventKitUI.h>

@interface FACalendarEventController ()
@property (nonatomic) FCAlertView *accessDeniedAlertView;
@property (nonatomic) FCAlertView *accessRestrictedAlertView;
@end

@implementation FACalendarEventController

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.accessDeniedAlertView = [[FCAlertView alloc] initWithTitle:NSLocalizedString(@"Access Denied", nil) message:NSLocalizedString(@"Can't add item to calendar because calendar access was denied. Open settings to change the privacy settings for Zapt.", nil) cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) cancelBlock:nil];
        self.accessRestrictedAlertView = [[FCAlertView alloc] initWithTitle:NSLocalizedString(@"Access Restricted", nil) message:NSLocalizedString(@"Can't add item to calendar because of active restrictions (possibly parental controls). Disable those restrictions and try again.", nil) cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) cancelBlock:nil];
    }
    
    return self;
}

- (void)addCalendarEventForContent:(FATraktContent *)content withViewController:(UIViewController *)viewController
{
    [self addCalendarEventForContent:content withViewController:viewController requestAccess:YES];
}

- (void)addCalendarEventForContent:(FATraktContent *)content withViewController:(UIViewController *)viewController requestAccess:(BOOL)shouldRequestAccess
{
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    if (authStatus == EKAuthorizationStatusNotDetermined && shouldRequestAccess) {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            [self addCalendarEventForContent:content withViewController:viewController requestAccess:NO];
        }];
        
        return;
    }
    
    if (authStatus == EKAuthorizationStatusAuthorized) {
        
        if (content.first_aired_utc) {
            EKEvent *event = [EKEvent eventWithEventStore:eventStore];
            
            NSTimeInterval runtime = FATimeIntervalHours(1);
            
            if ([content isKindOfClass:[FATraktEpisode class]]) {
                FATraktEpisode *episode = (FATraktEpisode *)content;
                
                if (episode.show.runtime) {
                    runtime = episode.show.runtime.floatValue * 60;
                }
                
                event.title = [NSString stringWithFormat:@"%@ - %@", episode.show.title, [FAInterfaceStringProvider nameForEpisode:episode long:NO capitalized:YES]];
                event.notes = [NSString stringWithFormat:@"%@", episode.title];
            }
            
            event.startDate = content.first_aired_utc;
            event.endDate = [content.first_aired_utc dateByAddingTimeInterval:runtime];
            event.availability = EKEventAvailabilityBusy;
            
            EKEventViewController *eventVC = [[EKEventViewController alloc] init];
            eventVC.event = event;
            [viewController presentViewControllerInsideNavigationController:eventVC animated:YES completion:nil];
        }
        
    } else if (authStatus == EKAuthorizationStatusRestricted) {
        [self.accessRestrictedAlertView show];
    } else {
        [self.accessDeniedAlertView show];
    }
}

@end
