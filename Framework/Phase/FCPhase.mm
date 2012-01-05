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

#import "FCPhase.h"
#import "FCError.h"
#import "FCLua.h"

@implementation FCPhase
@synthesize name = _name;
@synthesize namePath = _namePath;
@synthesize parent = _parent;
@synthesize children = _children;
@synthesize activeChild = _activeChild;
@synthesize luaTable = _luaTable;
@synthesize delegate = _delegate;
@synthesize activateTimer = _activateTimer;
@synthesize deactivateTimer = _deactivateTimer;
@synthesize state = _state;
@synthesize luaLoaded = _luaLoaded;

@synthesize luaUpdateFunc = _luaUpdateFunc;
@synthesize luaWasAddedToQueueFunc = _luaWasAddedToQueueFunc;
@synthesize luaWasRemovedFromQueueFunc = _luaWasRemovedFromQueueFunc;
@synthesize luaWillActivateFunc = _luaWillActivateFunc;
@synthesize luaIsNowActiveFunc = _luaIsNowActiveFunc;
@synthesize luaWillDeactivateFunc = _luaWillDeactivateFunc;
@synthesize luaIsNowDeactiveFunc = _luaIsNowDeactiveFunc;

-(id)initWithName:(NSString *)name
{
	self = [super init];
	if (self) {
		_name = name;
		_children = [NSMutableDictionary dictionary];
		_state = kFCPhaseStateInactive;
		
		_luaUpdateFunc = [_name stringByAppendingString:@"Phase.Update"];
		_luaWasAddedToQueueFunc = [_name stringByAppendingString:@"Phase.WasAddedToQueue"];
		_luaWasRemovedFromQueueFunc = [_name stringByAppendingString:@"Phase.WasRemovedFromQueue"];
		_luaWillActivateFunc = [_name stringByAppendingString:@"Phase.WillActivate"];
		_luaIsNowActiveFunc = [_name stringByAppendingString:@"Phase.IsNowActive"];
		_luaWillDeactivateFunc = [_name stringByAppendingString:@"Phase.WillDeactivate"];
		_luaIsNowDeactiveFunc = [_name stringByAppendingString:@"Phase.IsNowDeactive"];
		_luaLoaded = NO;
	}
	return self;
}

-(FCPhaseUpdate)update:(float)dt
{
	FC_ASSERT([_delegate respondsToSelector:@selector(update:)]);
	
	FCPhaseUpdate ret = [_delegate update:dt];
	
	[[FCLua instance].coreVM call:_luaUpdateFunc required:NO withSig:@""];
	
	return ret;
}

-(void)wasAddedToQueue
{
	if (_luaLoaded == NO) 
	{
		NSString* path = [_name stringByAppendingString:@"phase"];
		[[FCLua instance].coreVM loadScriptOptional:path];
		_luaLoaded = YES;
	}

	if ([_delegate respondsToSelector:@selector(wasAddedToQueue)]) 
	{
		[_delegate wasAddedToQueue];
		[[FCLua instance].coreVM call:_luaWasAddedToQueueFunc required:NO withSig:@""];
	}
}

-(void)wasRemovedFromQueue
{
	if ([_delegate respondsToSelector:@selector(wasRemovedFromQueue)]) 
	{
		[_delegate wasRemovedFromQueue];		
		[[FCLua instance].coreVM call:_luaWasRemovedFromQueueFunc required:NO withSig:@""];
	}
}

-(void)willActivate
{
	if ([_delegate respondsToSelector:@selector(willActivate)]) 
	{
		_activateTimer = [_delegate willActivate];
		[[FCLua instance].coreVM call:_luaWillActivateFunc required:NO withSig:@""];
	}
}

-(void)isNowActive
{
	if ([_delegate respondsToSelector:@selector(isNowActive)]) 
	{
		[_delegate isNowActive];		
		[[FCLua instance].coreVM call:_luaIsNowActiveFunc required:NO withSig:@""];
	}
}

-(void)willDeactivate
{
	if ([_delegate respondsToSelector:@selector(willDeactivate)]) 
	{
		_deactivateTimer = [_delegate willDeactivate];		
		[[FCLua instance].coreVM call:_luaWillDeactivateFunc required:NO withSig:@""];
	}
}

-(void)isNowDeactive
{
	if ([_delegate respondsToSelector:@selector(isNowDeactive)])
	{
		[_delegate isNowDeactive];
		[[FCLua instance].coreVM call:_luaIsNowDeactiveFunc required:NO withSig:@""];
	}
}

@end
