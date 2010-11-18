//
//  JTextPosition.h
//  JKit
//
//  Created by Jeremy Tregunna on 10-10-24.
//  Copyright 2010 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JTextPosition : NSObject
{
	NSUInteger _position;
}


@property (nonatomic, assign) NSUInteger position;


+ (JTextPosition*)positionWithInteger:(NSUInteger)position;


@end
