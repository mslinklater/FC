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

#import "FCPhaseManager.h"
#import "FCError.h"

#if defined (FC_LUA)
#import "FCLua.h"

static int lua_AddPhaseToQueue( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);

	const char* pPhaseName = lua_tostring( _state, -1);

	NSString* stringPhaseName = [NSString stringWithUTF8String:pPhaseName];
	
	[[FCPhaseManager instance] addPhaseToQueue:stringPhaseName];
	
	return 0;
}

static int lua_DeactivatePhase( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(-1, LUA_TSTRING);
	
	const char* pPhaseName = lua_tostring( _state, -1);
	
	NSString* stringPhaseName = [NSString stringWithUTF8String:pPhaseName];
	
	[[FCPhaseManager instance] deactivatePhase:stringPhaseName];
	
	return 0;	
}

#endif // defined(FC_LUA)

@implementation FCPhaseManager
@synthesize rootPhase = _rootPhase;
@synthesize phaseQueue = _phaseQueue;
@synthesize activePhases = _activePhases;

#pragma mark - Object Lifecycle

+(FCPhaseManager*)instance
{
	static FCPhaseManager* pInstance;
	
	if (!pInstance) {
		pInstance = [[FCPhaseManager alloc] init];
	}
	return pInstance;
}

#if defined (FC_LUA)
+(void)registerLuaFunctions:(FCLuaVM *)lua
{	
//	[lua createGlobalTable:@"FCPhaseManager"];
	lua->CreateGlobalTable("FCPhaseManager");
//	[lua registerCFunction:lua_AddPhaseToQueue as:@"FCPhaseManager.AddPhaseToQueue"];
	lua->RegisterCFunction(lua_AddPhaseToQueue, "FCPhaseManager.AddPhaseToQueue");
//	[lua registerCFunction:lua_DeactivatePhase as:@"FCPhaseManager.DeactivatePhase"];
	lua->RegisterCFunction(lua_DeactivatePhase, "FCPhaseManager.DeactivatePhase");
}
#endif

-(id)init
{
	self = [super init];
	if (self) {
		_phaseQueue = [NSMutableArray array];
		_rootPhase = [[FCPhase alloc] initWithName:@"root"];
		_activePhases = [NSMutableArray array];
	}
	return self;
}

-(void)deactivatePhase:(NSString*)name
{
	// make sure active phase exists with that name
	
	NSArray* activePhasesConst = [_activePhases copy];

	for( FCPhase* phase in activePhasesConst )
	{
		if ([phase.name isEqualToString:name]) 
		{
			FCPhase* freshPhase = [_phaseQueue objectAtIndex:0];
			[_activePhases addObject:freshPhase];
			[_phaseQueue removeObject:freshPhase];
			
			[freshPhase willActivate];
			
			freshPhase.state = kFCPhaseStateActivating;
			
			[phase willDeactivate];
			
			phase.state = kFCPhaseStateDeactivating;
			return;
		}
	}

	FC_FATAL( std::string("Phase ") + [name UTF8String] + " is not active" );
}

-(void)update:(float)dt
{
	// check for empty active phases - if so, pull the first one down
	
	if ([_activePhases count] == 0) 
	{
		if ([_phaseQueue count] > 0) 
		{
			FCPhase* firstPhase = [_phaseQueue objectAtIndex:0];
			
			[firstPhase willActivate];
			
			firstPhase.state = kFCPhaseStateActivating;
			[_activePhases addObject:firstPhase];
			[_phaseQueue removeObject:firstPhase];
		}
	}

	// update phases in the active array
	
	NSArray* activePhasesConst = [_activePhases copy];
	
	for( FCPhase* phase in activePhasesConst)
	{
		switch ([phase update:dt]) {
			case kFCPhaseUpdateOK:
				break;
			case kFCPhaseUpdateDeactivate:
			{
				[self deactivatePhase:phase.name];
			}
			break;
			default:
				break;
		}
		
		// update phase timers etc

		switch (phase.state) {
			case kFCPhaseStateActivating:
				if (phase.activateTimer <= 0.0) {
					phase.state = kFCPhaseStateUpdating;
					[phase isNowActive];
				} else {
					phase.activateTimer -= dt;
				}
				break;
				
			case kFCPhaseStateDeactivating:
				if (phase.deactivateTimer <= 0.0) {
					phase.state = kFCPhaseStateInactive;
					[phase isNowDeactive];
					[_activePhases removeObject:phase];
				} else {
					phase.deactivateTimer -= dt;
				}
				break;
			default:
				break;
		}
	}
}

-(FCPhase*)createPhaseWithName:(NSString*)name
{
	return [[FCPhase alloc] initWithName:name];
}

-(void)attachPhase:(FCPhase*)phase toParent:(FCPhase*)parentPhase
{
	if (parentPhase == nil) {
		parentPhase = _rootPhase;
	}
	
	phase.parent = parentPhase;
	[parentPhase.children setValue:phase forKey:phase.name];
}

-(void)addPhaseToQueue:(NSString*)name
{
	// find phase

	FCPhase* thisPhase = [_rootPhase.children valueForKey:name];
	
	FC_ASSERT( thisPhase );
	
	[_phaseQueue addObject:thisPhase];
	
	[thisPhase wasAddedToQueue];
}

@end
