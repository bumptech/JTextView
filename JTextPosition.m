//
//  JTextPosition.m
//  JKit
//
//  Created by Jeremy Tregunna on 10-10-24.
//  Copyright 2010 Jeremy Tregunna. All rights reserved.
//

#import "JTextPosition.h"


@implementation JTextPosition


@synthesize position = _position;


+ (JTextPosition*)positionWithInteger:(NSUInteger)position
{
	JTextPosition* e = [[JTextPosition alloc] init];
	e.position = position;
	return [e autorelease];
}


@end
