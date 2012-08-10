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

#import "FCInput_apple.h"
#import "FCViewManager_apple.h"

#include "Shared/Framework/Input/FCInput.h"

void plt_FCInput_SetTapSubscriberFunc( FCInputPlatformTapSubscriber func );
void plt_FCInput_AddTapToView( std::string viewName );
void plt_FCInput_RemoveTapFromView( std::string viewName );

static FCInput_apple* s_pInstance = 0;

void plt_FCInput_SetTapSubscriberFunc( FCInputPlatformTapSubscriber func )
{
	[FCInput_apple instance].tapSubscriber = func;
}

void plt_FCInput_AddTapToView( std::string viewName )
{
	FC_ASSERT(s_pInstance);
	
	NSString* stringViewName = @(viewName.c_str());
	
	UIView* thisView = [[FCViewManager_apple instance] viewNamed:stringViewName];

	FC_ASSERT( thisView );
	
	UITapGestureRecognizer* gr = [[UITapGestureRecognizer alloc] initWithTarget:s_pInstance action:@selector(tapGestureTarget:)];
	
	[thisView addGestureRecognizer:gr];
	
	[s_pInstance.tapDictionary setValue:gr forKey:stringViewName];
}

void plt_FCInput_RemoveTapFromView( std::string viewName )
{
	FC_ASSERT(s_pInstance);
	
	NSString* stringViewName = @(viewName.c_str());
	
	UIView* thisView = [[FCViewManager_apple instance] viewNamed:stringViewName];
	
	FC_ASSERT( thisView );
	
	UITapGestureRecognizer* gr = [s_pInstance.tapDictionary valueForKey:stringViewName];
	
	FC_ASSERT(gr);
	
	[thisView removeGestureRecognizer:gr];
	
	[s_pInstance.tapDictionary removeObjectForKey:stringViewName];
}

@implementation FCInput_apple

+(FCInput_apple*)instance
{
	if (!s_pInstance) {
		s_pInstance = [[FCInput_apple alloc] init];
	}
	return s_pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		_tapDictionary = [NSMutableDictionary dictionary];
	}
	return self;
}

-(void)tapGestureTarget:(UITapGestureRecognizer*)gr
{
	NSArray* keys = [_tapDictionary allKeys];
	
	for (NSString* key in keys)
	{
		if ([_tapDictionary valueForKey:key] == gr) {
			UIView* thisView = [[FCViewManager_apple instance] viewNamed:key];
			FC_ASSERT(thisView);
			
			CGPoint point = [gr locationInView:thisView];
			CGSize size = thisView.frame.size;
			FCVector2f pos;
			pos.x = point.x / size.width;
			pos.y = point.y / size.height;
			
			_tapSubscriber( [key UTF8String], pos );
			return;
		}
	}
	
	FC_ASSERT(0);
}

@end
