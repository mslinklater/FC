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

#import "FCCore.h"

#import "FCAnalytics.h"
#import "FCCaps.h"
#import "GANTracker.h"
#import "FCLua.h"

#pragma mark - Lua Interface

static int Lua_SetAccountId( lua_State* lua )
{
	const char* accountID = lua_tostring(lua, -1);
	[[FCAnalytics instance] setAccountID:[NSString stringWithUTF8String:accountID]];
	return 0;
}

static int Lua_StartSession( lua_State* lua )
{
	[[FCAnalytics instance] eventStartPlaySession];
	return 0;
}

static int Lua_EndSession( lua_State* lua )
{
	[[FCAnalytics instance] eventEndPlaySession];
	return 0;
}

//----------------------------------------------------------------------------------------------------------------------

@implementation FCAnalytics

static const int kVariableScopeVisitor = 1;
static const int kVariableScopeSession = 2;
static const int kVariableScopePage = 3;

static const int kVariableOSVersion = 1;
static const int kVariableDeviceType = 2;
static const int kVariableAppPirated = 3;

@synthesize accountID = _accountID;
@synthesize sessionTime = _sessionTime;

#pragma mark - FCSingleton

+(FCAnalytics*)instance
{
	static FCAnalytics* pInstance;
	if (!pInstance) {
		pInstance = [[FCAnalytics alloc] init];
	}
	return pInstance;
}

#pragma mark - Object Lifecycle

-(id)init
{
	self = [super init];
	if (self) {
		// blah
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)shutdown
{
	[[GANTracker sharedTracker] stopTracker];
}

+(void)registerLuaFunctions:(FCLuaVM *)lua
{
	[lua createGlobalTable:@"FCAnalytics"];
	[lua registerCFunction: Lua_SetAccountId as:@"FCAnalytics.SetAccountID"];
	[lua registerCFunction: Lua_StartSession as:@"FCAnalytics.StartSession"];
	[lua registerCFunction: Lua_EndSession as:@"FCAnalytics.EndSession"];
}

#pragma mark - Setters

-(void)timer
{
	self.sessionTime++;
}

-(void)setAccountID:(NSString *)accountID
{
	NSAssert( _accountID == nil, @"Setting analytics account more than once");
	
	_accountID = accountID;
	
	[[GANTracker sharedTracker] startTrackerWithAccountID:accountID
										   dispatchPeriod:1
												 delegate:nil];
	
	// register system variables
	
	self.sessionTime = 0;
	
	sessionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
}

#pragma mark - Events

-(void)event:(NSString*)event action:(NSString*)action label:(NSString*)label value:(int)value
{
	NSError* error;
	
	if (![[GANTracker sharedTracker] trackEvent:event
										 action:action
										  label:label
										  value:value
									  withError:&error]) 
	{
		FC_ERROR(@"Error");
	}	
}

-(void)eventStartPlaySession
{
	[self event:@"Game" action:@"StartPlaySession" label:@"Start" value:-1];
}

-(void)eventEndPlaySession
{
	[self event:@"Game" action:@"PlaySessionDuration" label:@"End" value:self.sessionTime];
}

//-(void)gameLevelPlayed:(NSString*)levelInfo
//{
//	NSError* error;
//	
//	if (![[GANTracker sharedTracker] trackEvent:@"Game"
//										 action:@"LevelPlayed"
//										  label:levelInfo
//										  value:-1
//									  withError:&error]) 
//	{
//		FC_ERROR(@"Error");
//		// Handle error here
//	}	
//}

//-(void)registerSystemValues
//{
//	NSError* error;
//	
//	if (![[GANTracker sharedTracker] trackEvent:@"Device"
//										 action:@"OSVersion"
//										  label:[[FCCaps instance] valueForKey:kFCCapsOSVersion]
//										  value:-1
//									  withError:&error]) 
//	{
//		FC_ERROR(@"Error");
//		// Handle error here
//	}
//
//	if (![[GANTracker sharedTracker] trackEvent:@"Device"
//										 action:@"ModelID"
//										  label:[[FCCaps instance] valueForKey:kFCCapsHardwareModelID]
//										  value:-1
//									  withError:&error]) 
//	{
//		FC_ERROR(@"Error");
//		// Handle error here
//	}
//
//	if (![[GANTracker sharedTracker] trackEvent:@"Device"
//										 action:@"Language"
//										  label:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]
//										  value:-1
//									  withError:&error]) 
//	{
//		FC_ERROR(@"Error");
//		// Handle error here
//	}
//
//	if (![[GANTracker sharedTracker] trackEvent:@"Device"
//										 action:@"Country"
//										  label:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]
//										  value:-1
//									  withError:&error]) 
//	{
//		FC_ERROR(@"Error");
//		// Handle error here
//	}
//}

@end

#endif // TARGET_OS_IPHONE
