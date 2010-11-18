//
//  JTextRange.h
//  JKit
//
//  Created by Jeremy Tregunna on 10-10-24.
//  Copyright 2010 Jeremy Tregunna. All rights reserved.
//

#import <UIKit/UIKit.h>


@class JTextPosition;


@interface JTextRange : UITextRange
{
	UITextPosition* _start;
	UITextPosition* _end;
}


+ (JTextRange*)rangeWithStart:(JTextPosition*)startPosition end:(JTextPosition*)endPosition;
- (NSUInteger)length;
- (void)setStartPosition:(JTextPosition*)position;
- (void)setEndPosition:(JTextPosition*)position;


@end
