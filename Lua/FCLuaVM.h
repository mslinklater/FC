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

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

extern "C" {
	#include <lua.h>
}

typedef int(*tLuaCallableCFunction)(lua_State*);

@interface FCLuaVM : NSObject {
	lua_State* _state;
}
@property(nonatomic, readonly) lua_State* state;

-(void)loadScript:(NSString*)path;
-(void)loadScriptOptional:(NSString*)path;
-(void)executeLine:(NSString*)line;
-(void)addStandardLibraries;
-(void)createGlobalTable:(NSString*)tableName;
-(void)registerCFunction:(tLuaCallableCFunction)func as:(NSString*)name;
-(void)removeCFunction:(NSString*)name;
-(int)getStackSize;

// Get
-(long)globalNumber:(NSString*)name;

#if TARGET_OS_IPHONE
-(UIColor*)globalColor:(NSString*)name;
#endif

// Set
-(void)setGlobal:(NSString*)global integer:(long)number;
-(void)setGlobal:(NSString*)global number:(double)number;
-(void)setGlobal:(NSString*)global boolean:(BOOL)value;

#if TARGET_OS_IPHONE
-(void)setGlobal:(NSString*)global color:(UIColor*)color;
#endif

// Function calling
-(void)call:(NSString*)func required:(BOOL)required withSig:(NSString*)sig, ...;

// Debug functions
-(void)dumpStack;
-(void)dumpCallstack;
@end
