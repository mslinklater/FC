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

#import "FCLuaVM.h"
#import "FCLuaMemory.h"
#import "FCLuaCommon.h"

extern "C" {
	#import "lauxlib.h"
	#import "lualib.h"
}

#import "FCError.h"

void common_LoadScriptForState(NSString* path, lua_State* _state, BOOL optional);

void common_LoadScriptForState(NSString* path, lua_State* _state, BOOL optional)
{
	NSString* filePath;
	
	// load via FCConnect - if not, get the binary out the bundle

	// if this is FC source, load from main bundle as plaintext

	if ([path rangeOfString:@"fc_"].location == 0) 
	{
		filePath = [[NSBundle mainBundle] pathForResource:[path lowercaseString] ofType:@"lua"];
	}
	else
	{
#if defined (DEBUG)
		path = [NSString stringWithFormat:@"lua/%@", path];
#else
		path = [NSString stringWithFormat:@"luabin/%@", path];
#endif
		filePath = [[NSBundle mainBundle] pathForResource:[path lowercaseString] ofType:@"lua"];		
	}

	if(filePath == nil)
	{ 
		if (!optional) {
			FC_FATAL1(@"Cannot load Lua file '%@'", path);
		} else {
			return;
		}
	}
	
	int ret = luaL_loadfile(_state, [filePath UTF8String]);
	
	switch (ret) {
		case LUA_ERRSYNTAX:
			FCLua_DumpStack(_state);
			FC_FATAL1(@"Syntax error on load of Lua file '%@'", path);
			break;			
		case LUA_ERRMEM:
			FCLua_DumpStack(_state);
			FC_FATAL1(@"Memory error on load of Lua file '%@'", path);
			break;			
		case LUA_ERRFILE:
			FCLua_DumpStack(_state);
			FC_FATAL1(@"File error on load of Lua file '%@'", path);
			break;			
		case LUA_ERRERR:
			FCLua_DumpStack(_state);
			FC_FATAL1(@"Error on load of Lua file '%@'", path);
			break;			
		case LUA_ERRRUN:
			FCLua_DumpStack(_state);
			FC_FATAL1(@"Run error on load of Lua file '%@'", path);
			break;			
		default:
			break;
	}
	
	ret = lua_pcall(_state, 0, 0, 0);
	
	switch (ret) {
		case LUA_ERRRUN:
			FCLua_DumpStack(_state);
			FC_FATAL1(@"Runtime error in Lua file '%@'", path);
			break;
		case LUA_ERRMEM:
			FC_FATAL1(@"Memory error in Lua file '%@'", path);
			break;
		case LUA_ERRERR:
			FC_FATAL1(@"Error while running error handling function in Lua file '%@'", path);
			break;			
		default:
			break;
	}
}

static int lua_LoadScript( lua_State* _state )
{
	NSString* path = [NSString stringWithCString:lua_tostring(_state, -1) encoding:NSUTF8StringEncoding];
	common_LoadScriptForState(path, _state, NO);
	return 0;
}

static int lua_LoadScriptOptional( lua_State* _state )
{
	NSString* path = [NSString stringWithCString:lua_tostring(_state, -1) encoding:NSUTF8StringEncoding];
	common_LoadScriptForState(path, _state, YES);
	return 0;
}

#pragma mark - Internal Interface

static int panic (lua_State *L) {
	(void)L;  /* to avoid warnings */
	const char* pString = lua_tostring(L, -1);
	FCLua_DumpStack(L);
	FC_FATAL1(@"PANIC: unprotected error in call to Lua API '%@'", [NSString stringWithCString:pString encoding:NSUTF8StringEncoding]);
	return 0;
}

@implementation FCLuaVM
@synthesize state = _state;

#pragma mark - Object Lifecycle

-(id)init
{
	self = [super init];
	if(self)
	{
		_state = lua_newstate(FCLuaAlloc, NULL);
		
		if (_state) {
			lua_atpanic(_state, &panic);
		}
		
		if (!_state) {
			FC_FATAL(@"lua_newstate");
		}
		
		// load core functions
		
		[self registerCFunction:lua_LoadScript as:@"FCLoadScript"];
	}
	return self;
}

-(void)dealloc
{
	lua_close(_state);
}

#pragma mark - Lua

-(void)loadScript:(NSString*)path
{
	common_LoadScriptForState(path, _state, NO);
}

-(void)loadScriptOptional:(NSString*)path
{
	common_LoadScriptForState(path, _state, YES);
}

-(void)executeLine:(NSString *)line
{
	int ret = luaL_loadbuffer(_state, [line UTF8String], [line length], "Injected");
	
	switch (ret) {
		case LUA_ERRSYNTAX:
			FC_ERROR1(@"Syntax error on load of Lua line '%@'", line);
			break;			
		case LUA_ERRMEM:
			FC_ERROR1(@"Memory error on load of Lua line '%@'", line);
			break;			
		default:
			break;
	}
	
	ret = lua_pcall(_state, 0, 0, 0);
	
	switch (ret) {
		case LUA_ERRRUN:
			FCLua_DumpStack(_state);
			FC_ERROR1(@"Runtime error in Lua line '%@'", line);
			break;
		case LUA_ERRMEM:
			FC_ERROR1(@"Memory error in Lua line '%@'", line);
			break;
		case LUA_ERRERR:
			FC_ERROR1(@"Error while running error handling function in Lua line '%@'", line);
			break;
		default:
			break;
	}

}

-(void)addStandardLibraries
{
	luaL_openlibs(_state);
}

-(void)registerCFunction:(tLuaCallableCFunction)func as:(NSString *)name
{
	NSArray* components = [name componentsSeparatedByString:@"."];
	
	NSUInteger numComponents = [components count];
	
	for (NSUInteger i = 0; i < numComponents - 1; i++) {
		if (i == 0) {
			lua_getglobal(_state, [[components objectAtIndex:i] UTF8String]);
		} else {
			lua_getfield(_state, -1, [[components objectAtIndex:i] UTF8String]);
		}
	}
	
	lua_pushcfunction(_state, func);
	if (numComponents == 1) {
		lua_setglobal(_state, [[components objectAtIndex:numComponents - 1] UTF8String]);
	} else {
		lua_setfield(_state, -2, [[components objectAtIndex:numComponents - 1] UTF8String]);
	}
	
	lua_pop(_state, (int)(numComponents - 1));
}

-(void)removeCFunction:(NSString *)name
{
	NSArray* components = [name componentsSeparatedByString:@"."];
	
	NSUInteger numComponents = [components count];
	
	for (NSUInteger i = 0; i < numComponents - 1; i++) {
		if (i == 0) {
			lua_getglobal(_state, [[components objectAtIndex:i] UTF8String]);
		} else {
			lua_getfield(_state, -1, [[components objectAtIndex:i] UTF8String]);
		}
	}
	
	lua_pushnil(_state);
	
	if (numComponents == 1) {
		lua_setglobal(_state, [[components objectAtIndex:numComponents - 1] UTF8String]);
	} else {
		lua_setfield(_state, -2, [[components objectAtIndex:numComponents - 1] UTF8String]);
	}
	
	lua_pop(_state, (int)(numComponents - 1));
}

-(void)createGlobalTable:(NSString*)tableName
{
	// need table descent
	
	lua_newtable(_state);
	lua_setglobal(_state, [tableName UTF8String]);
}

-(void)destroyGlobalTable:(NSString*)tableName
{
	// need table descent
	lua_pushnil(_state);
	lua_setglobal(_state, [tableName UTF8String]);
}

#pragma mark - Getters

-(long)globalNumber:(NSString*)name
{
	// need table descent
	
	lua_getglobal(_state, [name UTF8String]);
	if (!lua_isnumber(_state, -1)) {
		NSLog(@"ERROR - Global '%@' is not a number", name);
		exit(1);
	}
	return lua_tointeger(_state, -1);
}

#if TARGET_OS_IPHONE
-(UIColor*)globalColor:(NSString*)name
{
	// need table descent
	
	lua_getglobal(_state, [name UTF8String]);
	if (!lua_istable(_state, -1)) {
		NSLog(@"ERROR - Global '%@' is not a color", name);
		exit(1);
	}	
	// TODO: table size check
	
	// red
	lua_getfield(_state, -1, "r");
	if (!lua_isnumber(_state, -1)) {
		exit(1);
	}
	float red = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	// green
	lua_getfield(_state, -1, "g");
	if (!lua_isnumber(_state, -1)) {
		exit(1);
	}
	float green = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	// blue
	lua_getfield(_state, -1, "b");
	if (!lua_isnumber(_state, -1)) {
		exit(1);
	}
	float blue = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	// alpha
	lua_getfield(_state, -1, "a");
	if (!lua_isnumber(_state, -1)) {
		exit(1);
	}
	float alpha = (float)lua_tonumber(_state, -1);
	lua_pop(_state, 1);
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
#endif

#pragma mark - Setters

-(void)setGlobal:(NSString*)global integer:(long)number
{
	// need table descent
	
	lua_pushinteger(_state, number);
	lua_setglobal(_state, [global UTF8String]);
}

-(void)setGlobal:(NSString*)global number:(double)number
{
	// need table descent
	
	lua_pushnumber(_state, number);
	lua_setglobal(_state, [global UTF8String]);
}

-(void)setGlobal:(NSString*)name boolean:(BOOL)value
{
	NSArray* components = [name componentsSeparatedByString:@"."];
	
	NSUInteger numComponents = [components count];
	
	for (NSUInteger i = 0; i < numComponents - 1; i++) {
		if (i == 0) {
			lua_getglobal(_state, [[components objectAtIndex:i] UTF8String]);
		} else {
			lua_getfield(_state, -1, [[components objectAtIndex:i] UTF8String]);
		}
	}
	
	lua_pushboolean(_state, value);

	if (numComponents == 1) {
		lua_setglobal(_state, [[components objectAtIndex:numComponents - 1] UTF8String]);
	} else {
		lua_setfield(_state, -2, [[components objectAtIndex:numComponents - 1] UTF8String]);
	}
	
	lua_pop(_state, (int)(numComponents - 1));
}

#if TARGET_OS_IPHONE
-(void)setGlobal:(NSString *)global color:(UIColor*)color
{
	// need table descent
	
	FC_ASSERT( CGColorGetNumberOfComponents(color.CGColor) == 4);
	
	const CGFloat* components = CGColorGetComponents(color.CGColor);
	lua_newtable(_state);
	lua_pushnumber(_state, components[0]);
	lua_setfield(_state, -2, "r");
	lua_pushnumber(_state, components[1]);
	lua_setfield(_state, -2, "g");
	lua_pushnumber(_state, components[2]);
	lua_setfield(_state, -2, "b");
	lua_pushnumber(_state, components[3]);
	lua_setfield(_state, -2, "a");
	lua_setglobal(_state, [global UTF8String]);
}
#endif

-(void)call:(NSString*)func required:(BOOL)required withSig:(NSString*)sig, ...
{
	// NOTE - add specialist sig variations of this if perf becomes a problem

	va_list vl;
	int narg, nres;
	
	va_start(vl, sig);
	
	NSArray* components = [func componentsSeparatedByString:@"."];
	
	lua_getglobal(_state, [[components objectAtIndex:0] UTF8String]);
	
	if (lua_isnil(_state, -1)) {
		if (required) {
			FC_FATAL1(@"Can't find function '%@'", func);
		} else {
			lua_pop(_state, lua_gettop(_state));
			FC_ASSERT(lua_gettop(_state) == 0);
			return;
		}
	}
	
	NSUInteger numComponents = [components count];
	int numExtraStackPopsNeeded = 0;
	
	for (NSUInteger i = 1; i < numComponents; ++i) {
		lua_getfield(_state, -1, [[components objectAtIndex:i] UTF8String]);
		numExtraStackPopsNeeded++;
	}

	if (!lua_isfunction(_state, -1)) {
		if (required) {
			FC_FATAL1(@"Calling a function defined in Lua '%@'", func);
		} else
		{
			lua_pop(_state, lua_gettop(_state));
			FC_ASSERT(lua_gettop(_state) == 0);
			return;
		}
	}

	const char* csig = [sig UTF8String];
	
	for (narg = 0; *csig; narg++) {
		luaL_checkstack(_state, 1, "too many arguments");
		switch (*csig) {
			case 'd': /* double argument */
				lua_pushnumber(_state, va_arg(vl, double));
				break;
			case 'i': /* integer argument */
				lua_pushinteger(_state, va_arg(vl, int));
				break;
			case 's': /* string argument */
				lua_pushstring(_state, va_arg(vl, char*));
				break;
			case 'b': /* bool argument */
				lua_pushboolean(_state, va_arg(vl, bool));
				break;
			case 't': /* table argument */
			{
				char* tableName = va_arg(vl, char*);
				lua_getglobal(_state, tableName);
				if (!lua_istable(_state, -1)) 
				{
					NSString* tableNSString = [NSString stringWithFormat:@"%s", tableName];
					FC_FATAL1(@"Trying to pass table argument which is not a table", tableNSString);
				}					
				break;
			}
			case '>':
				csig++;
				goto endargs;
			default:
				NSLog(@"ERROR - invalid signature option to 'call' '%c'", *csig);
				break;
		}
		csig++;
	}
	
endargs:
	
	nres = (int)strlen(csig);
	
	if (lua_pcall(_state, narg, nres, 0) != 0) {
		FC_LOG2(@"ERROR calling '%@': %@", func, [NSString stringWithUTF8String:lua_tostring(_state, -1)]);
		[self dumpCallstack];
		FC_HALT;
	}
	
	//
	
	nres = -nres;
	
	while (*csig) {
		switch (*csig++) {
			case 'd': /* double result */
				FC_ASSERT(lua_isnumber(_state, nres));
				*va_arg(vl, double*) = lua_tonumber(_state, nres);
				break;
				
			case 'i': /* int result */
				FC_ASSERT(lua_isnumber(_state, nres));
				*va_arg(vl, int*) = (int)lua_tointeger(_state, nres);
				break;
				
			case 's': /* string result */
				FC_ASSERT(lua_isstring(_state, nres));
				*va_arg(vl, const char **) = lua_tostring(_state, nres);
				break;

			case 'b': /* boolean result */
				FC_ASSERT(lua_isboolean(_state, nres));
				*va_arg(vl, bool*) = lua_toboolean(_state, nres);
				break;

			default:
				FC_FATAL(@"Unknown Lua function return type" );
				break;
		}
		nres++;
	}
	
	lua_pop(_state, lua_gettop(_state));
	
	FC_ASSERT(lua_gettop(_state) == 0);

	va_end(vl);
	
	lua_gc( _state, LUA_GCCOLLECT, 0 );
}

#pragma mark - Debug

-(int)getStackSize
{
	return lua_gettop(_state);
}

-(void)dumpStack
{
	FCLua_DumpStack( self.state );
}

-(void)dumpCallstack
{
	lua_Debug entry;
	int depth = 0;
	
	while (lua_getstack(_state, depth, &entry)) {
		int status = lua_getinfo(_state, "Sln", &entry);
		if (!status) {
			NSLog(@"ERROR in dumpCallstack");
		}
		NSLog(@"%s(%d): %s\n", entry.short_src, entry.currentline, entry.name ? entry.name : "?");
		depth++;
	}
}

@end
