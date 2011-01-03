//
//  JTextView.h
//  JKit
//
//  Created by Jeremy Tregunna on 10-10-24.
//  Copyright (c) 2010 Jeremy Tregunna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "JTextCaret.h"

static NSString* const kJTextViewDataDetectorLinkKey = @"kJTextViewDataDetectorLinkKey";
static NSString* const kJTextViewDataDetectorPhoneNumberKey = @"kJTextViewDataDetectorPhoneNumberKey";
static NSString* const kJTextViewDataDetectorDateKey = @"kJTextViewDataDetectorDateKey";
static NSString* const kJTextViewDataDetectorAddressKey = @"kJTextViewDataDetectorAddressKey";

@protocol JTextViewDataDetectorDelegate <NSObject>
@optional
- (void) linkClicked:(id) data ofType:(NSString*)linkType;
@end


@interface JTextView : UIScrollView <UIKeyInput>
{
	NSMutableAttributedString* _textStore;
	UIColor* _textColor;
	UIFont* _font;
	BOOL _editable;
	
	// Data detectors should also allow you to supply a style you want to use for different types of
	// detectors. This is not yet implemented, but will be.
	UIDataDetectorTypes _dataDetectorTypes;
@private
	JTextCaret* caret;
	CTFrameRef textFrame;
	id<JTextViewDataDetectorDelegate> _dataDelegate;
}


@property (nonatomic, assign) id<JTextViewDataDetectorDelegate> dataDelegate;
@property (nonatomic, retain) NSMutableAttributedString* attributedText;
@property (nonatomic, retain) UIColor* textColor;
@property (nonatomic, retain) UIFont* font;
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;


@end
