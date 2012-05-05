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

#import "FCPersistentData.h"
#import "FCCore.h"

#if defined (FC_LUA)
#import "FCLua.h"

#pragma mark - Lua Interface

static int lua_Save( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[[FCPersistentData instance] saveData];
	return 0;
}

static int lua_Load( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[[FCPersistentData instance] loadData];
	return 0;
}

static int lua_Clear( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[[FCPersistentData instance] clearData];
	return 0;
}

static int lua_Print( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	[[FCPersistentData instance] printData];
	return 0;
}

static int lua_SetBool( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(-2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(-1, LUA_TBOOLEAN);
	
	const char* pVarName = lua_tostring( _state, -2);
	bool value = lua_toboolean(_state, -1);
	
	NSString* stringName = [NSString stringWithFormat:@"%s", pVarName];
	if (value) 
	{
		[[FCPersistentData instance] addObject:[NSNumber numberWithBool:YES] forKey:stringName];
	}
	else
	{
		[[FCPersistentData instance] addObject:[NSNumber numberWithBool:NO] forKey:stringName];		
	}
	
	return 0;
}

static int lua_GetBool( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);

	const char* pVarName = lua_tostring( _state, -1 );

	NSNumber* number = [[FCPersistentData instance] objectForKey:[NSString stringWithFormat:@"%s", pVarName]];
	
	if (number == nil) 
	{
		lua_pushnil( _state );
	}
	else if ([number boolValue] == YES) 
	{
		lua_pushboolean(_state, 1);
	}
	else
	{
		lua_pushboolean(_state, 0);		
	}
	return 1;	// false, true or nil
}

static int lua_SetString( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(-2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);
	
	const char* pKey = lua_tostring( _state, -2);
	const char* pValue = lua_tostring(_state, -1);
	
	NSString* stringKey = [NSString stringWithFormat:@"%s", pKey];
	NSString* stringValue = [NSString stringWithFormat:@"%s", pValue];
	[[FCPersistentData instance] addObject:stringValue forKey:stringKey];	
	return 0;
}

static int lua_GetString( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);
	
	const char* pKey = lua_tostring( _state, -1 );
	
	NSString* value = [[FCPersistentData instance] objectForKey:[NSString stringWithFormat:@"%s", pKey]];
	
	if (value == nil) 
	{
		lua_pushnil( _state );
	}
	else
	{
		lua_pushstring(_state, [value UTF8String]);		
	}
	return 1;	// false, true or nil
}

static int lua_SetNumber( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(2);
	FC_LUA_ASSERT_TYPE(-2, LUA_TSTRING);
	FC_LUA_ASSERT_TYPE(-1, LUA_TNUMBER);
	
	const char* pKey = lua_tostring( _state, -2);
	double value = lua_tonumber(_state, -1);
	
	NSString* stringKey = [NSString stringWithFormat:@"%s", pKey];
	NSNumber* number = [NSNumber numberWithDouble:value];
	[[FCPersistentData instance] addObject:number forKey:stringKey];	
	return 0;
}

static int lua_GetNumber( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);
	
	const char* pKey = lua_tostring( _state, -1 );
	
	NSNumber* value = [[FCPersistentData instance] objectForKey:[NSString stringWithFormat:@"%s", pKey]];
	
	if (value == nil) 
	{
		lua_pushnil( _state );
	}
	else
	{
		lua_pushnumber(_state, [value doubleValue]);
	}
	return 1;
}

#endif // defined(FC_LUA)

#pragma mark - Implementation

@implementation FCPersistentData

@synthesize dataRoot = _dataRoot;

+(FCPersistentData*)instance
{
	static FCPersistentData* pInstance;
	
	if (!pInstance) 
	{
		pInstance = [[FCPersistentData alloc] init];
	}
	return pInstance;
}

#if defined (FC_LUA)
+(void)registerLuaFunctions:(FCLuaVM*)lua
{
//	[lua createGlobalTable:@"FCPersistentData"];
	lua->CreateGlobalTable("FCPersistentData");
//	[lua registerCFunction:lua_Save as:@"FCPersistentData.Save"];
	lua->RegisterCFunction(lua_Save, "FCPersistentData.Save");
//	[lua registerCFunction:lua_Load as:@"FCPersistentData.Load"];
	lua->RegisterCFunction(lua_Load, "FCPersistentData.Load");
//	[lua registerCFunction:lua_Clear as:@"FCPersistentData.Clear"];
	lua->RegisterCFunction(lua_Clear, "FCPersistentData.Clear");
//	[lua registerCFunction:lua_Print as:@"FCPersistentData.Print"];
	lua->RegisterCFunction(lua_Print, "FCPersistentData.Print");
//	[lua registerCFunction:lua_SetBool as:@"FCPersistentData.SetBool"];
	lua->RegisterCFunction(lua_SetBool, "FCPersistentData.SetBool");
//	[lua registerCFunction:lua_GetBool as:@"FCPersistentData.GetBool"];
	lua->RegisterCFunction(lua_GetBool, "FCPersistentData.GetBool");
//	[lua registerCFunction:lua_SetString as:@"FCPersistentData.SetString"];
	lua->RegisterCFunction(lua_SetString, "FCPersistentData.SetString");
//	[lua registerCFunction:lua_GetString as:@"FCPersistentData.GetString"];
	lua->RegisterCFunction(lua_GetString, "FCPersistentData.GetString");
//	[lua registerCFunction:lua_SetNumber as:@"FCPersistentData.SetNumber"];
	lua->RegisterCFunction(lua_SetNumber, "FCPersistentData.SetNumber");
//	[lua registerCFunction:lua_GetNumber as:@"FCPersistentData.GetNumber"];
	lua->RegisterCFunction(lua_GetNumber, "FCPersistentData.GetNumber");
}
#endif // defined(FC_LUA)

-(NSString*)filename
{
	NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentDirectory = [documentDirectories objectAtIndex:0];
	return [documentDirectory stringByAppendingPathComponent:@"savedata"];
}

#pragma mark - Object Lifespan

-(id)init
{
	self = [super init];
	if (self) 
	{
	}
	return self;
}


#pragma mark - Load and Save

-(void)loadData
{
	FC_LOG("FCPersisteneData:loadData");
	self.dataRoot = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filename]];
	
	if (!self.dataRoot) {
		self.dataRoot = [NSMutableDictionary dictionary];
	}
}

-(void)saveData
{
	FC_LOG("FCPersisteneData:saveData");

	// threaded
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		[NSKeyedArchiver archiveRootObject:self.dataRoot toFile:[self filename]];
	});
	
}

-(void)clearData
{
	self.dataRoot = [NSMutableDictionary dictionary];
	[self saveData];
}

-(void)printData
{
	FC_LOG([[self.dataRoot description ] UTF8String]);
}

-(id)objectForKey:(NSString*)key
{
	FC_ASSERT(self.dataRoot != nil);
	return [self.dataRoot valueForKey:key];
}

-(void)addObject:(id)object forKey:(NSString*)key
{
	FC_ASSERT(self.dataRoot != nil);
	[self.dataRoot setObject:object forKey:key];
}

@end
