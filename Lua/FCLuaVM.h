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

#import <Foundation/Foundation.h>

extern "C" {
	#include "lua.h"
}

typedef int(*tLuaCallableCFunction)(lua_State*);

@interface FCLuaVM : NSObject {
	lua_State* _state;
}
@property(nonatomic, readonly) lua_State* state;

-(void)loadFileFromMainBundle:(NSString*)path;
-(void)addStandardLibraries;
-(void)createGlobalTable:(NSString*)tableName;
-(void)registerCFunction:(tLuaCallableCFunction)func as:(NSString*)name;

// Get
-(long)globalNumber:(NSString*)name;
-(UIColor*)globalColor:(NSString*)name;

// Set
-(void)setGlobal:(NSString*)global integer:(long)number;
-(void)setGlobal:(NSString*)global number:(double)number;
-(void)setGlobal:(NSString*)global color:(UIColor*)color;

// Function calling
-(void)call:(NSString*)func withSig:(NSString*)sig, ...;

// Debug functions
-(void)dumpStack;
-(void)dumpCallstack;
@end
