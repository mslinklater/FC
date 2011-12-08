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

#import "FCLuaVM.h"
#import "FCLuaMemory.h"
#import "FCLuaCommon.h"

extern "C" {
	#import "lauxlib.h"
	#import "lualib.h"
}

#import "FCError.h"

void common_LoadScriptForState(NSString* path, lua_State* _state);
int Lua_LoadScript( lua_State* _state );


void common_LoadScriptForState(NSString* path, lua_State* _state)
{
	NSString* filePath = [[NSBundle mainBundle] pathForResource:path ofType:@"lua"];

	if(filePath == nil)
	{ 
		FC_FATAL1(@"Cannot load Lua file '%@'", path);
	}
	
	int ret = luaL_loadfile(_state, [filePath UTF8String]);
	
	switch (ret) {
		case LUA_ERRSYNTAX:
			FC_FATAL1(@"Syntax error on load of Lua file '%@'", path);
			break;			
		case LUA_ERRMEM:
			FC_FATAL1(@"Memory error on load of Lua file '%@'", path);
			break;			
		default:
			break;
	}
	
	ret = lua_pcall(_state, 0, 0, 0);
	
	switch (ret) {
		case LUA_ERRRUN:
			FCLuaCommon_DumpStack(_state);
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

int Lua_LoadScript( lua_State* _state )
{
	NSString* path = [NSString stringWithCString:lua_tostring(_state, -1) encoding:NSUTF8StringEncoding];
	common_LoadScriptForState(path, _state);
	return 0;
}

#pragma mark - Internal Interface

static int panic (lua_State *L) {
	(void)L;  /* to avoid warnings */
	const char* pString = lua_tostring(L, -1);
	FCLuaCommon_DumpStack(L);
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
		
		[self registerCFunction:Lua_LoadScript as:@"FCLoadScript"];
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
	common_LoadScriptForState(path, _state);
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

-(void)createGlobalTable:(NSString*)tableName
{
	lua_newtable(_state);
	lua_setglobal(_state, [tableName UTF8String]);
}

#pragma mark - Getters

-(long)globalNumber:(NSString*)name
{
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
	lua_pushinteger(_state, number);
	lua_setglobal(_state, [global UTF8String]);
}

-(void)setGlobal:(NSString*)global number:(double)number
{
	lua_pushnumber(_state, number);
	lua_setglobal(_state, [global UTF8String]);
}

#if TARGET_OS_IPHONE
-(void)setGlobal:(NSString *)global color:(UIColor*)color
{
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
		} else
			return;
	}
	
	NSUInteger numComponents = [components count];
	
	for (NSUInteger i = 1; i < numComponents; ++i) {
		lua_getfield(_state, -1, [[components objectAtIndex:i] UTF8String]);
	}

	if (!lua_isfunction(_state, -1)) {
		if (required) {
			FC_FATAL1(@"Calling a function defined in Lua '%@'", func);
		} else
			return;
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
		NSLog(@"ERROR calling '%@': %s", func, lua_tostring(_state, -1));
		[self dumpCallstack];
	}
	
	//
	
	nres = -nres;
	
	while (*csig) {
		switch (*csig++) {
			case 'd': /* double result */
				if (!lua_isnumber(_state, nres)) {
					NSLog(@"ERROR");
				}
				*va_arg(vl, double*) = lua_tonumber(_state, nres);
				break;
				
			case 'i': /* int result */
				if (!lua_isnumber(_state, nres)) {
					NSLog(@"ERROR");
				}
				*va_arg(vl, int*) = (int)lua_tointeger(_state, nres);
				break;
				
			case 's': /* string result */
				if (!lua_isstring(_state, nres)) {
					NSLog(@"ERROR");
				}
				*va_arg(vl, const char **) = lua_tostring(_state, nres);
				break;
				
			default:
				NSLog(@"Error");
				break;
		}
		nres++;
	}
	
	va_end(vl);
}

#pragma mark - Debug

-(void)dumpStack
{
	FCLuaCommon_DumpStack( self.state );
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
