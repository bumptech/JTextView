//
//  JTextView.h
//  JKit
//
//  Created by Jeremy Tregunna on 10-10-24.
//  Copyright (c) 2010 Jeremy Tregunna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTextCaret.h"


@interface JTextView : UIScrollView <UIKeyInput>
{
	NSMutableAttributedString* _textStore;
	UIColor* _textColor;
	UIFont* _font;
	BOOL _editable;
	UIDataDetectorTypes _dataDetectorTypes;
@private
	JTextCaret* caret;
}


@property (nonatomic, copy) NSMutableAttributedString* attributedText;
@property (nonatomic, retain) UIColor* textColor;
@property (nonatomic, retain) UIFont* font;
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;


@end
