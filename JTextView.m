//
//  JTextView.m
//  JKit
//
//  Created by Jeremy Tregunna on 10-10-24.
//  Copyright (c) 2010 Jeremy Tregunna. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "JTextView.h"


static CGFloat const kJTextViewPaddingSize = 2.0f;


@implementation JTextView


@synthesize attributedText = _textStore;
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize editable = _editable;
@synthesize dataDetectorTypes = _dataDetectorTypes;


#pragma mark -
#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
        _textStore = [[NSMutableAttributedString alloc] init];
		_textColor = [UIColor blackColor];
		_editable = NO;
		caret = [[JTextCaret alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)dealloc
{
	[caret release];
    [_textStore release];
    [super dealloc];
}


#pragma mark -
#pragma mark Responder chain and touch handling


- (BOOL)canBecomeFirstResponder
{
    return self.editable;
}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self becomeFirstResponder];
}


#pragma mark -
#pragma mark Text drawing


- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(context, rect);
	
	[self.backgroundColor set];
	CGContextFillRect(context, rect);
	
	CTFontRef font = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
	[self.attributedText addAttribute:(NSString*)kCTFontAttributeName value:(id)font range:NSMakeRange(0, self.attributedText.length)];
	CFRelease(font);
	
	CGFloat width = CGRectGetWidth(self.bounds) - kJTextViewPaddingSize * 2;
	CGSize textSize = [[self.attributedText string] sizeWithFont:self.font
											   constrainedToSize:CGSizeMake(width, UINT_MAX)
												   lineBreakMode:UILineBreakModeWordWrap];
	CGContextTranslateCTM(context, 0, textSize.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, 1.0));
	
	UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(kJTextViewPaddingSize, -(kJTextViewPaddingSize - 1), width, textSize.height)];
	
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
	CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path.CGPath, NULL);
	CFRelease(framesetter);
	CTFrameDraw(textFrame, context);
	CFRelease(textFrame);
}


#pragma mark -
#pragma mark UIKeyInput delegate methods


- (BOOL)hasText
{
    if(self.attributedText.length > 0)
        return YES;
    return NO;
}


- (void)insertText:(NSString*)aString
{
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:aString];
    [self.attributedText appendAttributedString:attributedString];
    [attributedString release];
    [self setNeedsDisplay];
}


- (void)deleteBackward
{
	if(self.attributedText.length != 0)
	{
		NSRange range = NSMakeRange(self.attributedText.length - 1, 1);
		[self.attributedText deleteCharactersInRange:range];
		[self setNeedsDisplay];
	}
}


@end
