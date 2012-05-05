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
#import "FCCore.h"
#import "FCTwitter.h"
#import "FCApplication.h"
#import "FCLua.h"

static FCTwitter* s_pInstance;

static int lua_CanTweet( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	lua_pushboolean(_state, [s_pInstance canTweet]);
	
	return 1;
}

static int lua_TweetWithText( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);

	NSString* text = [NSString stringWithUTF8String:lua_tostring(_state, 1)];

	lua_pushboolean(_state, [s_pInstance tweetWithText:text]);
	
	return 1;
}

static int lua_AddHyperlink( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	NSString* hyperlink = [NSString stringWithUTF8String:lua_tostring(_state, 1)];
	
	lua_pushboolean(_state, [s_pInstance addHyperlink:hyperlink]);
	
	return 1;
}

static int lua_Send( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[s_pInstance send];
	return 0;
}

@implementation FCTwitter
@synthesize vc = _vc;

+(FCTwitter*)instance
{
	if (!s_pInstance) {
		s_pInstance = [[FCTwitter alloc] init];
	}
	return s_pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		_vc = [[TWTweetComposeViewController alloc] init];
//		[[FCLua instance].coreVM createGlobalTable:@"FCTwitter"];
		FCLua::Instance()->CoreVM()->CreateGlobalTable("FCTwitter");
//		[[FCLua instance].coreVM registerCFunction:lua_CanTweet as:@"FCTwitter.CanSendTweet"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_CanTweet, "FCTwitter.CanSendTweet");
//		[[FCLua instance].coreVM registerCFunction:lua_TweetWithText as:@"FCTwitter.TweetWithText"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_TweetWithText, "FCTwitter.TweetWithText");
//		[[FCLua instance].coreVM registerCFunction:lua_AddHyperlink as:@"FCTwitter.AddHyperlink"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_AddHyperlink, "FCTwitter.AddHyperlink");
//		[[FCLua instance].coreVM registerCFunction:lua_Send as:@"FCTwitter.Send"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Send, "FCTwitter.Send");
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
	[[[FCApplication instance] rootViewController] presentModalViewController:_vc animated:YES];
}

@end
