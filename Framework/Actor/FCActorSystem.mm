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

#import "FCActorSystem.h"
#import "FCActor.h"
#import "FCPhysics.h"
#import "FCXMLData.h"
#import "FCResource.h"
#import "FCCore.h"
#import "FCLua.h"

static FCActorSystem* s_pInstance;

#pragma mark - Lua Interface

#if defined (FC_LUA)
static int lua_Reset( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(0);
	
	[s_pInstance reset];
	return 0;
}

static int lua_GetActorPosition( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCActor* actor = [[FCActorSystem instance].actorHandleDictionary objectForKey:[NSNumber numberWithInt:lua_tointeger(_state, 1)]];
	FC::Vector3f pos = actor.position;
	
	lua_pushnumber(_state, pos.x);
	lua_pushnumber(_state, pos.y);
	lua_pushnumber(_state, pos.z);
	
	return 3;
}

static int lua_SetActorPosition( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(4);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(4, LUA_TNUMBER);
	
	FCHandle handle = lua_tointeger(_state, 1);
	
	FC::Vector3f pos;
	pos.x = lua_tonumber(_state, 2);
	pos.y = lua_tonumber(_state, 3);
	pos.z = lua_tonumber(_state, 4);
	
	FCActor* actor = [[FCActorSystem instance].actorHandleDictionary objectForKey:[NSNumber numberWithInt:handle]];

	actor.position = pos;
	return 0;
}

static int lua_GetActorLinearVelocity( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	
	FCHandle handle = lua_tointeger(_state, 1);
	FCActor* actor = [[FCActorSystem instance].actorHandleDictionary objectForKey:[NSNumber numberWithInt:handle]];
	FC::Vector3f vel = actor.linearVelocity;
	
	lua_pushnumber(_state, vel.x);
	lua_pushnumber(_state, vel.y);
	lua_pushnumber(_state, vel.z);
	return 3;
}

static int lua_SetActorLinearVelocity( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(4);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(4, LUA_TNUMBER);
	
	FCHandle handle = lua_tointeger(_state, 1);
	FCActor* actor = [[FCActorSystem instance].actorHandleDictionary objectForKey:[NSNumber numberWithInt:handle]];
	actor.linearVelocity = FC::Vector3f( lua_tonumber(_state, 2), lua_tonumber(_state, 3), lua_tonumber(_state, 4) );
	return 0;
}

static int lua_ApplyImpulse( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(4);
	FC_LUA_ASSERT_TYPE(1, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(2, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(3, LUA_TNUMBER);
	FC_LUA_ASSERT_TYPE(4, LUA_TNUMBER);
	
	FCHandle handle = lua_tointeger(_state, 1);
	FCActor* actor = [[FCActorSystem instance].actorHandleDictionary objectForKey:[NSNumber numberWithInt:handle]];
	[actor applyImpulse:FC::Vector3f(lua_tonumber(_state, 2), lua_tonumber(_state, 3), lua_tonumber(_state, 4)) atWorldPos:actor.position];
	return 0;
}

#endif

@implementation FCActorSystem

@synthesize allActorsArray = _allActorsArray;
@synthesize updateActorsArray = _updateActorsArray;
@synthesize renderActorsArray = _renderActorsArray;
@synthesize tapGestureActorsArray = _tapGestureActorsArray;
@synthesize deleteList = _deleteList;
@synthesize classArraysDictionary = _classArraysDictionary;
@synthesize actorFullNameDictionary = _actorFullNameDictionary;
@synthesize actorHandleDictionary = _actorHandleDictionary;

#pragma mark - FCSingleton protocol

+(id)instance
{
	if (!s_pInstance) {
		s_pInstance = [[FCActorSystem alloc] init];
	}
	return s_pInstance;
}

#pragma mark - Object Lifetime

-(id)init
{
	self = [super init];
	if (self) 
	{
		_allActorsArray = [[NSMutableArray alloc] init];
		_updateActorsArray = [[NSMutableArray alloc] init];
		_renderActorsArray = [[NSMutableArray alloc] init];
		_tapGestureActorsArray = [[NSMutableArray alloc] init];
		_deleteList = [[NSMutableArray alloc] init];
		_classArraysDictionary = [[NSMutableDictionary alloc] init];
		_actorFullNameDictionary = [[NSMutableDictionary alloc] init];
		_actorHandleDictionary = [[NSMutableDictionary alloc] init];
		
#if defined (FC_LUA)
		[[FCLua instance].coreVM createGlobalTable:@"FCActorSystem"];
		[[FCLua instance].coreVM registerCFunction:lua_Reset as:@"FCActorSystem.Reset"];
		[[FCLua instance].coreVM registerCFunction:lua_GetActorPosition as:@"FCActorSystem.GetPosition"];
		[[FCLua instance].coreVM registerCFunction:lua_SetActorPosition as:@"FCActorSystem.SetPosition"];
		[[FCLua instance].coreVM registerCFunction:lua_GetActorLinearVelocity as:@"FCActorSystem.GetLinearVelocity"];
		[[FCLua instance].coreVM registerCFunction:lua_SetActorLinearVelocity as:@"FCActorSystem.SetLinearVelocity"];
		[[FCLua instance].coreVM registerCFunction:lua_SetActorLinearVelocity as:@"FCActorSystem.ApplyImpulse"];
#endif
	}

	return self;
}

#pragma mark - New FCR Based methods

-(NSArray*)createActorsOfClass:(NSString *)actorClass withResource:(FCResource *)res name:(NSString *)name
{
	// Test is the actor class type you are requesting actually exists
	FC_ASSERT(NSClassFromString(actorClass));
	
	NSMutableArray* newActors = [NSMutableArray array];

	NSArray* actors = [res.xmlData arrayForKeyPath:@"fcr.scene.actor"];
	
	// create actors
	
	for(NSDictionary* actorDict in actors)
	{
		[newActors addObject:[self createActor:actorDict ofClass:actorClass withResource:res name:name]];
	}	

	NSArray* retArray = [NSArray arrayWithArray:newActors];
	return retArray;
}

-(id)createActor:(NSDictionary*)actorDict ofClass:(NSString *)actorClass withResource:(FCResource *)res name:(NSString *)name
{
	// get body
	
	NSString* bodyId = [actorDict valueForKey:[NSString stringWithUTF8String:kFCKeyBody.c_str()]];	
	NSArray* bodies = [res.xmlData arrayForKeyPath:@"fcr.physics.bodies.body"];
	
	// Find the body associated with this actor
	
	NSDictionary* bodyDict = nil;
	for(NSDictionary* body in bodies)
	{
		NSString* thisId = [body valueForKey:[NSString stringWithUTF8String:kFCKeyId.c_str()]];
		
		if ([thisId isEqualToString:bodyId]) 
		{
			bodyDict = body;
			break;
		}
	}
	
	// get model

	NSDictionary* modelDict = nil;
	NSString* modelId = [actorDict valueForKey:[NSString stringWithUTF8String:kFCKeyModel.c_str()]];
	if (modelId) 
	{
		NSArray* models = [res.xmlData arrayForKeyPath:@"fcr.models.model"];
		
		for(NSDictionary* model in models)
		{
			NSString* thisId = [model valueForKey:[NSString stringWithUTF8String:kFCKeyId.c_str()]];
			
			if ([thisId isEqualToString:modelId]) 
			{
				modelDict = model;
				break;
			}
		}
	}

	// instantiate actor
	
	id actor = [self actorOfClass:NSClassFromString(actorClass)];

	FCHandle handle = NewFCHandle();
	
	actor = [actor initWithDictionary:actorDict body:bodyDict model:modelDict resource:res name:name handle:handle];
//	((FCActor*)actor).handle = handle;

	// some more checks etc

	NSString* actorId = [actorDict valueForKey:[NSString stringWithUTF8String:kFCKeyId.c_str()]];

	if (name) // id is optional
	{
		((FCActor*)actor).fullName = [NSString stringWithFormat:@"%@_%@", name, actorId];
		FC_ASSERT([_actorFullNameDictionary valueForKey:((FCActor*)actor).fullName] == nil);
		[_actorFullNameDictionary setValue:actor forKey:((FCActor*)actor).fullName];
	}

	// add to class arrays dictionary
	
	if (![_classArraysDictionary valueForKey:actorClass]) 
	{
		NSMutableArray* classArray = [NSMutableArray array];
		[_classArraysDictionary setValue:classArray forKey:actorClass];
	}
	
	[[_classArraysDictionary valueForKey:actorClass] addObject:actor];

	// handle

	[_actorHandleDictionary setObject:actor forKey:[NSNumber numberWithInt:((FCActor*)actor).handle]];
	
	return actor;
}

#pragma mark - Old stuff
#pragma mark -

-(id)actorOfClass:(Class)actorClass
{
	if(!actorClass)
	{
#if TARGET_OS_IPHONE
		UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"ERROR - FCActorSystem actorOfClass" message:@"nil actorClass" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[errorView show];
#endif
		return nil;
	}
	
	id newActor = [actorClass alloc];
	[_allActorsArray addObject:newActor];

	if ([newActor needsUpdate]) {
		FC_ASSERT([newActor conformsToProtocol:@protocol(FCGameObjectUpdate) ]);
		[_updateActorsArray addObject:newActor];
	}
	
	if ([newActor needsRender]) {
		FC_ASSERT([newActor conformsToProtocol:@protocol(FCGameObjectRender) ]);
		[_renderActorsArray addObject:newActor];
	}

	if ([newActor respondsToTapGesture]) {
		[_tapGestureActorsArray addObject:newActor];
	}

	return newActor;
}

-(void)addToDeleteArray:(FCActor*)actor
{
	[_deleteList addObject:actor];
}

-(void)removeActor:(FCActor*)actor
{
	if (((FCActor*)actor).fullName) 
	{
		NSString* fullName = ((FCActor*)actor).Id;
		[_actorFullNameDictionary removeObjectForKey:fullName];
	}

	if ([actor needsUpdate]) {
		[_updateActorsArray removeObject:actor];
	}

	if ([actor needsRender]) {
		[_renderActorsArray removeObject:actor];
	}

	if ([actor respondsToTapGesture]) {
		[_tapGestureActorsArray removeObject:actor];
	}

	[_allActorsArray removeObject:actor];
	
	[[_classArraysDictionary valueForKey:NSStringFromClass([actor class])] removeObject:actor];
	
	[_actorHandleDictionary removeObjectForKey:[NSNumber numberWithInt:actor.handle]];
}

-(NSArray*)getActorsOfClass:(NSString*)actorClass
{
	return [_classArraysDictionary valueForKey:actorClass];
}

-(id)actorWithFullName:(NSString *)Id
{
	return [_actorFullNameDictionary valueForKey:Id];
}

-(id)actorWithHandle:(FCHandle)handle
{
	return [_actorHandleDictionary objectForKey:[NSNumber numberWithInt:handle]];
}

#pragma mark -
#pragma mark GameObjectLifetime methods

-(void)reset
{
	[self removeAllActors];
}

-(void)removeAllActors
{
	[_allActorsArray removeAllObjects];
	[_updateActorsArray removeAllObjects];
	[_renderActorsArray removeAllObjects];
	[_tapGestureActorsArray removeAllObjects];
	[_deleteList removeAllObjects];

	[_classArraysDictionary removeAllObjects];
	[_actorFullNameDictionary removeAllObjects];
	[_actorHandleDictionary removeAllObjects];
}

#pragma mark - GameObjectUpdate methods

-(void)update:(float)realTime gameTime:(float)gameTime
{	
	// remove actors on delete list
	
	for( FCActor* deleteActor in _deleteList )
	{
		[self removeActor:deleteActor];
	}

	[_deleteList removeAllObjects];
	
	// update active actors
	
	for( FCActor* actor in _updateActorsArray )
	{
		[actor update:gameTime];
	}
}

#pragma mark - GameObjectRender methods

-(NSArray*)renderGather
{
	return _renderActorsArray;
}

@end



