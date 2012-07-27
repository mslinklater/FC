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

#import <Twitter/Twitter.h>

#import "FCTwitter_apple.h"

#include "Shared/Core/FCCore.h"

extern UIViewController* FCRootViewController();

bool plt_FCTwitter_CanTweet();
bool plt_FCTwitter_TweetWithText( std::string text );
bool plt_FCTwitter_AddHyperlink( std::string hyperlink );
void plt_FCTwitter_Send();

bool plt_FCTwitter_CanTweet()
{
	return [[FCTwitter_apple instance] canTweet];
}

bool plt_FCTwitter_TweetWithText( std::string text )
{
	return [[FCTwitter_apple instance] tweetWithText:[NSString stringWithUTF8String:text.c_str()]];
}

bool plt_FCTwitter_AddHyperlink( std::string hyperlink )
{
	return [[FCTwitter_apple instance] addHyperlink:[NSString stringWithUTF8String:hyperlink.c_str()]];
}

void plt_FCTwitter_Send()
{
	[[FCTwitter_apple instance] send];
}

static FCTwitter_apple* s_pInstance;

@implementation FCTwitter_apple
@synthesize vc = _vc;

+(FCTwitter_apple*)instance
{
	if (!s_pInstance) {
		s_pInstance = [[FCTwitter_apple alloc] init];
	}
	return s_pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		_vc = [[TWTweetComposeViewController alloc] init];
	}
	return self;
}

-(BOOL)canTweet
{
	return [TWTweetComposeViewController canSendTweet];
}

-(BOOL)tweetWithText:(NSString *)text
{
	return [_vc setInitialText:text];
}

-(BOOL)addHyperlink:(NSString *)hyperlink
{
	return [_vc addURL:[NSURL URLWithString:hyperlink]];
}

-(void)send
{
	[FCRootViewController() presentModalViewController:_vc animated:YES];
}

@end
