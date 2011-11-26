//
//  FCLuaCommon.m
//  HeadPopper
//
//  Created by Martin Linklater on 23/11/2011.
//  Copyright (c) 2011 Curly Rocket Ltd. All rights reserved.
//

#import "FCLuaCommon.h"

#import "FCError.h"

void FCLuaCommon_DumpStack( lua_State* _state )
{
	NSString* hexAddress = [NSString stringWithFormat:@"0x%08x", _state];
	FC_LOG1(@"-- FCLuaVM:dumpStack (%@) --", hexAddress);
	int i;
	int top = lua_gettop(_state);
	for( i = 1 ; i <= top ; i++ )
	{
		int t = lua_type(_state, i);
		int negIndex = -(top - i) -1;
		switch(t)
		{
			case LUA_TSTRING:
				FC_LOG3(@"(%@/%@) string '%@'", [NSNumber numberWithInt:i], [NSNumber numberWithInt:negIndex], [NSString stringWithUTF8String:lua_tostring(_state, i)]);
				break;
			case LUA_TBOOLEAN:
				FC_LOG3(@"(%@/%@) boolean %@", [NSNumber numberWithInt:i], [NSNumber numberWithInt:negIndex], (lua_toboolean(_state, i) ? @"true" : @"false") );
				break;
			case LUA_TNUMBER:
				FC_LOG3(@"(%@/%@) number %@", [NSNumber numberWithInt:i], [NSNumber numberWithInt:negIndex], [NSNumber numberWithDouble:lua_tonumber(_state, i)]);
				break;
			default:
				FC_LOG3(@"(%@/%@) %@", [NSNumber numberWithInt:i], [NSNumber numberWithInt:negIndex], [NSString stringWithUTF8String:lua_typename(_state, t)]);
				break;
		}
	}
}
