/*
 Copyright (C) 2011 by Martin Linklater
 
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

#if TARGET_OS_IPHONE

#import "FCUIButton.h"

NSString* kFCUIButtonHidden = @"hidden";
NSString* kFCUIButtonParentView = @"parentview";
NSString* kFCUIButtonDefaultImage = @"defaultimage";
NSString* kFCUIButtonPressedImage = @"pressedimage";

@implementation FCUIButton

static NSMutableDictionary* sThemesDictionary;
static NSMutableDictionary* sCurrentTheme;

#pragma mark - Object Lifetime

+(void)initialize
{
	sThemesDictionary = [[NSMutableDictionary alloc] init];
}

#pragma mark - Themes

+(void)newThemeWithName:(NSString*)name
{
	sCurrentTheme = [[NSMutableDictionary alloc] init];
	[sThemesDictionary setValue:sCurrentTheme forKey:name];
}

+(void)setTheme:(NSString*)name
{
	sCurrentTheme = [sThemesDictionary valueForKey:name];
}

+(void)setThemeAttribute:(id)attribute forKey:(NSString*)key
{
	NSAssert(sCurrentTheme, @"Setting attribute on nil theme");
	
}

+(void)setThemeBool:(BOOL)value forKey:(NSString*)key
{
	NSAssert(sCurrentTheme, @"Setting attribute on nil theme");
	
}

+(UIButton*)buttonWithFrame:(CGRect)frame
{
	UIButton* button = [[[UIButton alloc] initWithFrame:frame] autorelease];
	
	return button;
}

@end

#endif // TARGET_OS_IPHONE
