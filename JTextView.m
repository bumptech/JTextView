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


@interface JTextView (PrivateMethods)
- (void)dataDetectorPassInRange:(NSRange)range;
- (void)receivedTap:(UITapGestureRecognizer*)recognizer;
@end


@implementation JTextView



@synthesize attributedText = _textStore;
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize editable = _editable;
@synthesize dataDetectorTypes = _dataDetectorTypes;
@synthesize dataDelegate = _dataDelegate;

#pragma mark -
#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
    {
 		_textStore = [[NSMutableAttributedString alloc] init];
		self.backgroundColor = [UIColor whiteColor];
		_textColor = [UIColor blackColor];
		_font = [[UIFont systemFontOfSize:[UIFont systemFontSize]] retain];
		_editable = NO;
		_dataDetectorTypes = UIDataDetectorTypeNone;
		caret = [[JTextCaret alloc] initWithFrame:CGRectZero];
		UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receivedTap:)] autorelease];
		[self addGestureRecognizer:tap];
    }
    return self;
}

- (void)dealloc
{
	CFRelease(textFrame);
	[_font release];
	[caret release];
	[_textStore release];
	[super dealloc];
}


#pragma mark -
#pragma mark Responder chain


- (BOOL)canBecomeFirstResponder
{
	return self.editable;
}


#pragma mark -
#pragma mark Text drawing


- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(context, rect);
	
	[self.backgroundColor set];
	CGContextFillRect(context, rect);
	
	NSRange textRange = NSMakeRange(0, self.attributedText.length);
	
	CTFontRef font = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
	[self.attributedText addAttribute:(NSString*)kCTFontAttributeName value:(id)font range:textRange];
	CFRelease(font);
	
	if(!self.editable)
		[self dataDetectorPassInRange:textRange];
	
	CGFloat width = CGRectGetWidth(self.bounds) - kJTextViewPaddingSize * 2;
	CGSize textSize = [[self.attributedText string] sizeWithFont:self.font
											   constrainedToSize:CGSizeMake(width, UINT_MAX)
												   lineBreakMode:UILineBreakModeWordWrap];
	CGContextTranslateCTM(context, 0, textSize.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, 1.0));
	
	UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(kJTextViewPaddingSize, -(kJTextViewPaddingSize - 1), width, textSize.height)];
	
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
	textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path.CGPath, NULL);
	CFRelease(framesetter);
	CTFrameDraw(textFrame, context);
	UIGraphicsPushContext(context);
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


#pragma mark -
#pragma mark Data detectors


- (void)dataDetectorPassInRange:(NSRange)range
{
	if (!self.dataDetectorTypes) {
		return;
	}
	NSError* error = NULL;
	NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:self.dataDetectorTypes error:&error];
	NSAssert(error == nil, @"Problem creating the link detector: %@", [error localizedDescription]);
	NSString* string = [self.attributedText string];
	
	[detector enumerateMatchesInString:string options:0 range:range usingBlock:^(NSTextCheckingResult* match, NSMatchingFlags flags, BOOL* stop){
		NSRange matchRange = [match range];
		// No way to call into Calendar, so don't detect dates
		if([match resultType] != NSTextCheckingTypeDate)
		{
			[self.attributedText addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:matchRange];
			[self.attributedText addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle] range:matchRange];
		}
		switch([match resultType])
		{
			case NSTextCheckingTypeLink:
			{
				NSURL* url = [match URL];
				[self.attributedText addAttribute:kJTextViewDataDetectorLinkKey value:url range:matchRange];
				break;
			}
			case NSTextCheckingTypePhoneNumber:
			{
				NSString* phoneNumber = [match phoneNumber];
				[self.attributedText addAttribute:kJTextViewDataDetectorPhoneNumberKey value:phoneNumber range:matchRange];
				break;
			}
			case NSTextCheckingTypeAddress:
			{
				NSDictionary* addressComponents = [match addressComponents];
				[self.attributedText addAttribute:kJTextViewDataDetectorAddressKey value:addressComponents range:matchRange];
				break;
			}
			case NSTextCheckingTypeDate:
			{
				//NSDate* date = [match date];
				//[self.attributedText addAttribute:kJTextViewDataDetectorDateKey value:date range:matchRange];
				break;
			}
		}
	}];
}


#pragma mark -
#pragma mark Touch handling


- (void)receivedTap:(UITapGestureRecognizer*)recognizer
{
	if(self.editable)
	{
		[self becomeFirstResponder];
		return;
	}
	
	CGPoint point = [recognizer locationInView:self];
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	NSArray* tempLines = (NSArray*)CTFrameGetLines(textFrame);
	CFIndex lineCount = [tempLines count];//CFArrayGetCount(lines);
	NSMutableArray* lines = [NSMutableArray arrayWithCapacity:lineCount];
	for(id elem in [tempLines reverseObjectEnumerator])
		[lines addObject:elem];
	CGPoint origins[lineCount];

	CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
	for(CFIndex idx = 0; idx < lineCount; idx++)
	{
		CTLineRef line = CFArrayGetValueAtIndex((CFArrayRef)lines, idx);
		CGRect lineBounds = CTLineGetImageBounds(line, context);
		lineBounds.origin.y += origins[idx].y;
		
		if(CGRectContainsPoint(lineBounds, point))
		{
			CFArrayRef runs = CTLineGetGlyphRuns(line);
			for(CFIndex j = 0; j < CFArrayGetCount(runs); j++)
			{
				CTRunRef run = CFArrayGetValueAtIndex(runs, j);
				NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
				BOOL result = NO;
				NSURL* url = [attributes objectForKey:kJTextViewDataDetectorLinkKey];
				NSString* phoneNumber = [attributes objectForKey:kJTextViewDataDetectorPhoneNumberKey];
				NSDictionary* addressComponents = [attributes objectForKey:kJTextViewDataDetectorAddressKey];
				NSDate* date = [attributes objectForKey:kJTextViewDataDetectorDateKey];
				if(url)
				{
					if ([_dataDelegate respondsToSelector:@selector(linkClicked:ofType:)]) {
						[_dataDelegate linkClicked:url ofType:kJTextViewDataDetectorLinkKey];
					} else {
						result = [[UIApplication sharedApplication] openURL:url];
					}
					return;
				}
				else if(phoneNumber)
				{
					
					if ([_dataDelegate respondsToSelector:@selector(linkClicked:ofType:)]) {
						[_dataDelegate linkClicked:phoneNumber ofType:kJTextViewDataDetectorPhoneNumberKey];
					} else {
						phoneNumber = [phoneNumber stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
						// The following code may be switched to if we absolutely need to remove everything but the numbers.
						//NSMutableString* strippedPhoneNumber = [NSMutableString stringWithCapacity:[phoneNumber length]]; // Can't be longer than that
						//for(NSUInteger i = 0; i < [phoneNumber length]; i++)
						//{
						//	if(isdigit([phoneNumber characterAtIndex:i]))
						//		[strippedPhoneNumber appendFormat:@"%c", [phoneNumber characterAtIndex:i]];
						//}
						//NSLog(@"*** phoneNumber = %@; strippedPhoneNumber = %@", phoneNumber, strippedPhoneNumber);
						NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]];
						result = [[UIApplication sharedApplication] openURL:url];
					}
					return;
				}
				else if(addressComponents)
				{
					if ([_dataDelegate respondsToSelector:@selector(linkClicked:ofType:)]) {
						[_dataDelegate linkClicked:addressComponents ofType:kJTextViewDataDetectorAddressKey];
					} else {
						NSMutableString* address = [NSMutableString string];
						NSString* temp = nil;
						if((temp = [addressComponents objectForKey:NSTextCheckingStreetKey]))
							[address appendString:temp];
						if((temp = [addressComponents objectForKey:NSTextCheckingCityKey]))
							[address appendString:[NSString stringWithFormat:@"%@%@", ([address length] > 0) ? @", " : @"", temp]];
						if((temp = [addressComponents objectForKey:NSTextCheckingStateKey]))
							[address appendString:[NSString stringWithFormat:@"%@%@", ([address length] > 0) ? @", " : @"", temp]];
						if((temp = [addressComponents objectForKey:NSTextCheckingZIPKey]))
							[address appendString:[NSString stringWithFormat:@" %@", temp]];
						if((temp = [addressComponents objectForKey:NSTextCheckingCountryKey]))
							[address appendString:[NSString stringWithFormat:@"%@%@", ([address length] > 0) ? @", " : @"", temp]];
						NSString* urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
						result = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
					}
					return;
				} else if(date)
				{
					if ([_dataDelegate respondsToSelector:@selector(linkClicked:ofType:)]) {
						[_dataDelegate linkClicked:date ofType:kJTextViewDataDetectorDateKey];
					} else {						
						NSLog(@"Unable to handle date: %@", date);
						result = NO;
					}
					return;
				}
			}
		}
	}
}

- (void)setText:(NSString*) newText;
{
	NSAttributedString *attribString = [[NSAttributedString alloc] initWithString:newText];
	[_textStore setAttributedString:attribString];
	[attribString release];
}
- (NSString*)text;
{
	return [_textStore string];
}

+ (CGFloat)suggestedHeightOfText:(NSString*)text forWidth:(float)maxWidth inFont:(UIFont*)font;
{
	// Accomodate for padding
	CGFloat width = maxWidth - kJTextViewPaddingSize * 2;
	CGSize textSize = [text sizeWithFont:font
					   constrainedToSize:CGSizeMake(width, UINT_MAX)
						   lineBreakMode:UILineBreakModeWordWrap];
	return textSize.height;
}

@end
