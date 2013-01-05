/*
 Copyright (C) 2011-2012 by Martin Linklater
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#if !defined( ADHOC )

#import "FCDebugMenu_apple.h"
#import "FCApplication_apple.h"

#include "Shared/Core/FCCore.h"
#include "Shared/FCPlatformInterface.h"

static FCDebugMenu_apple* s_pInstance;

void plt_FCDebugMenu_AddButton( FCHandle handle, const char* name, const FCColor4f& color )
{
	[[FCDebugMenu_apple instance] addButtonWithHandle:handle
												 text:[NSString stringWithUTF8String:name]
												color:[UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a]];
}

void plt_FCDebugMenu_Show()
{
	[[FCDebugMenu_apple instance] show];
}

void plt_FCDebugMenu_Hide()
{
	[[FCDebugMenu_apple instance] hide];
}

void plt_FCDebugMenu_AddSelection( FCHandle handle, const char* name, const FCColor4f& color )
{
	
}

void plt_FCDebugMenu_AddSelectionOption( FCHandle handle, const char* name )
{
	
}

@implementation FCDebugMenu_apple

+(FCDebugMenu_apple*)instance
{
	if (!s_pInstance) {
		s_pInstance = [[FCDebugMenu_apple alloc] initWithFrame:[UIScreen mainScreen].bounds];
	}
	return s_pInstance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(10, -frame.size.height, frame.size.width - 20, frame.size.height - 50)];
    if (self) {
		[FCRootViewController().view addSubview:self];
		
		self.backgroundColor = [UIColor blackColor];
		self.alpha = 0.8;
		
		mDebugButton = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 30, 30, 30)];
		mDebugButton.backgroundColor = [UIColor blackColor];
		mDebugButton.text = @"D";
		mDebugButton.textColor = [UIColor whiteColor];
		mDebugButton.textAlignment = UITextAlignmentCenter;
		mDebugButton.userInteractionEnabled = YES;
		mDebugButton.alpha = 0.2;

		mTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
		mTapRecognizer.numberOfTapsRequired = 1;
		[mDebugButton addGestureRecognizer:mTapRecognizer];
		
		[[FCApplication_apple instance] setDebugMenuButton:mDebugButton];
		
		mDisplayed = NO;
		
		mButtons = [NSMutableDictionary dictionary];
		mNextButtonPos = CGPointMake(10, 10);
		self.contentSize = CGSizeMake(frame.size.width - 20, 0);
    }
    return self;
}

-(void)dealloc
{
	[mDebugButton removeGestureRecognizer:mTapRecognizer];
}

-(void)tap:(id)sender
{
	if (mDisplayed) {
		[self hide];
	} else {
		[self show];
	}
}

-(void)show
{
	[FCRootViewController().view bringSubviewToFront:self];
	[UIView animateWithDuration:0.2 animations:^{
		self.frame = CGRectMake(10, 10, self.frame.size.width, self.frame.size.height);
	}];
	mDisplayed = YES;
}

-(void)hide
{
	[UIView animateWithDuration:0.2 animations:^{
		self.frame = CGRectMake(10, -(self.frame.size.height + 50), self.frame.size.width, self.frame.size.height);
	}];
	mDisplayed = NO;
}

-(void)buttonResponder:(id)sender
{
	uint32_t handle = [[mButtons objectForKey:[NSValue valueWithNonretainedObject:sender]] intValue];
	
	fc_FCDebugMenu_ButtonPressed( handle );
}

-(void)addButtonWithHandle:(uint32_t)h text:(NSString *)text color:(UIColor *)color
{
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitle:text forState:UIControlStateNormal];
	button.frame = CGRectMake(mNextButtonPos.x, mNextButtonPos.y, self.frame.size.width - 20, 30);
	button.backgroundColor = color;
	[button addTarget:self action:@selector(buttonResponder:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:button];
	
	[mButtons setObject:[NSNumber numberWithInt:h] forKey:[NSValue valueWithNonretainedObject:button]];
	
	mNextButtonPos.y += 50;
	
	self.contentSize = CGSizeMake( self.frame.size.width, mNextButtonPos.y );
}

@end

#endif
