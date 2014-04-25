//
//  FAKeyedArchiverDebugDelegate.m
//  Zapt
//
//  Created by Finn Wilke on 21/04/14.
//  Copyright (c) 2014 Finn Wilke. All rights reserved.
//

#import "FAKeyedArchiverDebugDelegate.h"

@implementation FAKeyedArchiverDebugDelegate

#pragma mark - NSKeyedArchiverDelegate

- (void)archiver:(NSKeyedArchiver *)archiver didEncodeObject:(id)object
{
    NSLog(@"archiver:%@ didEncodeObject:%@", archiver, object);
}

- (void)archiverDidFinish:(NSKeyedArchiver *)archiver
{
    NSLog(@"archiverDidFinish:%@", archiver);
}

- (id)archiver:(NSKeyedArchiver *)archiver willEncodeObject:(id)object
{
    NSLog(@"archiver:%@ willEncodeObject:%@", archiver, object);
    
    return object;
}

- (void)archiverWillFinish:(NSKeyedArchiver *)archiver
{
    NSLog(@"archiverWillFinish:%@", archiver);
}

- (void)archiver:(NSKeyedArchiver *)archiver willReplaceObject:(id)object withObject:(id)newObject
{
    NSLog(@"archiver:%@ willReplaceObject:%@ withObject:%@", archiver, object, newObject);
}

#pragma mark - NSKeyedUnarchiverDelegate

- (Class)unarchiver:(NSKeyedUnarchiver *)unarchiver cannotDecodeObjectOfClassName:(NSString *)name originalClasses:(NSArray *)classNames
{
    NSLog(@"unarchiver:%@ cannotDecodeObjectOfClassName:%@ originalClasses:%@", unarchiver, name, classNames);
    
    return nil;
}

- (id)unarchiver:(NSKeyedUnarchiver *)unarchiver didDecodeObject:(id)object
{
    NSLog(@"unarchiver:%@ didDecodeObject:%@", unarchiver, object);
    
    return object;
}

- (void)unarchiver:(NSKeyedUnarchiver *)unarchiver willReplaceObject:(id)object withObject:(id)newObject
{
    NSLog(@"unarchiver:%@ willReplaceObject:%@ withObject:%@", unarchiver, object, newObject);
}

- (void)unarchiverDidFinish:(NSKeyedUnarchiver *)unarchiver
{
    NSLog(@"unarchiverDidFinish:%@", unarchiver);
}

- (void)unarchiverWillFinish:(NSKeyedUnarchiver *)unarchiver
{
    NSLog(@"unarchiverWillFinish:%@", unarchiver);
}

@end
