//
//  JTextCaret.m
//  JKit
//
//  Created by Jeremy Tregunna on 10-11-18.
//  Copyright 2010 Jeremy Tregunna. All rights reserved.
//

#import "JTextCaret.h"


@implementation JTextCaret


@synthesize animated = _animated;


- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame]))
	{
		[self setBackgroundColor:[UIColor blueColor]];
		[self animationFadeOut];
	}
	return self;
}


#pragma mark -
#pragma mark Animations


- (void)animationFadeIn
{
	if(self.animated)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.25];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFadeOut)];
		self.alpha = 1.0f;
		[UIView commitAnimations];
	}
	else
		self.alpha = 1.0f;
}


- (void)animationFadeOut
{
	if(self.animated)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDelay:0.45];
		[UIView setAnimationDuration:0.25];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFadeIn)];
		self.alpha = 0.0f;
		[UIView commitAnimations];
	}
	else
		self.alpha = 1.0f;
}


@end
