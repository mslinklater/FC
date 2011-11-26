//
//  FCApp.m
//
//  Created by Martin Linklater on 28/10/2011.
//  Copyright (c) 2011 CurlyRocket. All rights reserved.
//

#import "FCApp.h"
#import "FCPersistentData.h"
#import "FCAnalytics.h"
#import "FCCaps.h"
#import "FCError.h"

static FCLuaVM* s_lua;

@implementation FCApp

+(void)coldBoot
{
	// register system lua hooks

	FCLuaVM* s_lua = [[FCLua instance] coreVM];
	
	[FCPersistentData registerLuaFunctions:s_lua];
	[FCAnalytics registerLuaFunctions:s_lua];
	[FCCaps registerLuaFunctions:s_lua];
	[FCError registerLuaFunctions:s_lua];

	[s_lua call:@"PrintTable" withSig:@"tb>", "FCCaps", true];
	[s_lua call:@"PrintTable" withSig:@"tb>", "FCPersistentData", true];
	[s_lua call:@"PrintTable" withSig:@"tb>", "FCAnalytics", true];

	[s_lua loadScript:@"main"];
	[s_lua call:@"App.ColdBoot" withSig:@""];
}

+(void)warmBoot
{
	[s_lua call:@"App.warmboot" withSig:@""];
}

+(void)shutdown
{
	[s_lua call:@"App.shutdown" withSig:@""];
}

+(void)update
{
	[[FCLua instance] updateThreads];
}

+(void)startInternalUpdate
{
	
}

+(void)stopInternalUpdate
{
	
}

+(FCLuaVM*)lua
{
	return s_lua;
}

@end
