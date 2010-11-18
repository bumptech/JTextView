//
//  JTextCaret.h
//  JKit
//
//  Created by Jeremy Tregunna on 10-11-18.
//  Copyright 2010 Jeremy Tregunna. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JTextCaret : UIView
{
	BOOL _animated;
}


@property (nonatomic, getter=isAnimated) BOOL animated;


- (void)animationFadeIn;
- (void)animationFadeOut;


@end
