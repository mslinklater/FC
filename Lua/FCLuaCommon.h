//
//  FCLuaCommon.h
//  HeadPopper
//
//  Created by Martin Linklater on 23/11/2011.
//  Copyright (c) 2011 Curly Rocket Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern "C" {
#import "lua.h"
#import "lauxlib.h"
#import "lualib.h"
}

extern void FCLuaCommon_DumpStack( lua_State* _state );
