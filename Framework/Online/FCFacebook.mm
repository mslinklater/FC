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

#import "FCFacebook.h"
#import "FCCore.h"

#if defined (FC_LUA)
#import "FCLua.h"

static int lua_ConnectWithAppId( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);
	
	NSString* appId = [NSString stringWithUTF8String:lua_tostring(_state, 1)];

	[[FCFacebook instance] connectWithAppId:appId];
	
	return 0;
}

static int lua_IsLoggedIn( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	if ([FCFacebook instance].loginStatus == kLoggedIn) {
		lua_pushboolean(_state, 1);
	} else {
		lua_pushboolean(_state, 0);		
	}
	return 1;
}

static int lua_Login( lua_State* _state )
{	
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	[[FCFacebook instance] login];
	return 0;
}

static int lua_Logout( lua_State* _state )
{	
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	[[FCFacebook instance] logout];
	return 0;
}

#endif // FC_LUA

static FCFacebook* s_pInstance;

@implementation FCFacebook
@synthesize facebook = _facebook;
@synthesize appId = _appId;
@synthesize loginStatus = _loginStatus;

+(FCFacebook*)instance
{
	if (!s_pInstance) {
		s_pInstance = [[FCFacebook alloc] init];
	}
	return s_pInstance;
}

-(id)init
{
	self = [super init];
	if( self )
	{
		_loginStatus = kOffline;
#if defined (FC_LUA)
//		[[FCLua instance].coreVM createGlobalTable:@"FCFacebook"];
		FCLua::Instance()->CoreVM()->CreateGlobalTable("FCFacebook");
//		[[FCLua instance].coreVM registerCFunction:lua_ConnectWithAppId as:@"FCFacebook.ConnectWithAppId"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_ConnectWithAppId, "FCFacebook.ConnectWithAppId");
//		[[FCLua instance].coreVM registerCFunction:lua_IsLoggedIn as:@"FCFacebook.IsLoggedIn"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_IsLoggedIn, "FCFacebook.IsLoggedIn");
//		[[FCLua instance].coreVM registerCFunction:lua_Login as:@"FCFacebook.Login"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Login, "FCFacebook.IsLoggedIn");
//		[[FCLua instance].coreVM registerCFunction:lua_Login as:@"FCFacebook.Logout"];
		FCLua::Instance()->CoreVM()->RegisterCFunction(lua_Logout, "FCFacebook.Logout");
#endif
	}
	return self;
}

-(void)connectWithAppId:(NSString*)appId
{
	_appId = appId;
	_facebook = [[Facebook alloc] initWithAppId:appId andDelegate:self];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
	}
}

-(void)login
{
	if (![_facebook isSessionValid]) {
		_loginStatus = kLoggingIn;
		[_facebook authorize:nil];
	}
}

-(void)logout
{
	_loginStatus = kLoggingOut;
	[_facebook logout];
}

#pragma mark - FBSessionDelegate methods

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];	
	
	_loginStatus = kLoggedIn;
}

-(void)fbDidLogout {
	_loginStatus = kOffline;
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
	_loginStatus = kOffline;
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt
{
	
}

- (void)fbSessionInvalidated
{
	_loginStatus = kOffline;
}

@end
