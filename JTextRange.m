//
//  JTextRange.m
//  JKit
//
//  Created by Jeremy Tregunna on 10-10-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JTextRange.h"
#import "JTextPosition.h"


@implementation JTextRange


+ (JTextRange*)rangeWithStart:(JTextPosition*)startPosition end:(JTextPosition*)endPosition
{
	JTextRange* e = [[JTextRange alloc] init];
	[e setStartPosition:startPosition];
	[e setEndPosition:endPosition];
	return [e autorelease];
}


#pragma mark -
#pragma mark Utility


- (NSUInteger)length
{
	return [(JTextPosition*)_end position] - [(JTextPosition*)_start position];
}


- (BOOL)isEmpty
{
	return [self length] == 0;
}


#pragma mark -
#pragma mark NSCopying protocol


- (id)copyWithZone:(NSZone*)zone
{
	JTextRange* copy = [[[self class] allocWithZone:zone] init];
	[copy setStartPosition:(JTextPosition*)_start];
	[copy setEndPosition:(JTextPosition*)_end];
	return copy;
}


#pragma mark -
#pragma mark Accessors


- (void)setStartPosition:(JTextPosition*)position
{
	[_start release];
	_start = [position retain];
}


- (void)setEndPosition:(JTextPosition*)position
{
	[_end release];
	_end = [position retain];
}


@end
