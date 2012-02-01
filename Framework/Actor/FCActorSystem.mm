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
	[s_pInstance reset];
	return 0;
}
#endif

@interface FCActorSystem(hidden)
-(id)createActor:(NSDictionary*)actorDict ofClass:(NSString*)actorClass withResource:(FCResource*)res named:(NSString*)name;
#if defined (FC_PHYSICS)
-(void)addJoint:(NSDictionary*)jointDict;
#endif
@end

@implementation FCActorSystem

@synthesize allActorsArray = _allActorsArray;
@synthesize updateActorsArray = _updateActorsArray;
@synthesize renderActorsArray = _renderActorsArray;
@synthesize tapGestureActorsArray = _tapGestureActorsArray;
@synthesize deleteList = _deleteList;
@synthesize classArraysDictionary = _classArraysDictionary;
@synthesize actorIdDictionary = _actorIdDictionary;
@synthesize actorNameDictionary = _actorNameDictionary;

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
		_actorIdDictionary = [[NSMutableDictionary alloc] init];
		_actorNameDictionary = [[NSMutableDictionary alloc] init];
		
#if defined (FC_LUA)
		[[FCLua instance].coreVM createGlobalTable:@"FCActorSystem"];
		[[FCLua instance].coreVM registerCFunction:lua_Reset as:@"FCActorSystem.Reset"];
#endif
	}

	return self;
}

#pragma mark - New FCR Based methods

-(NSArray*)createActorsOfClass:(NSString *)actorClass withResource:(FCResource *)res named:(NSString *)name
{
	// Test is the actor class type you are requesting actually exists
	FC_ASSERT(NSClassFromString(actorClass));
	
	NSMutableArray* newActors = [NSMutableArray array];

	NSArray* actors = [res.xmlData arrayForKeyPath:@"fcr.scene.actor"];
	
	// create actors
	
	for(NSDictionary* actorDict in actors)
	{
		[newActors addObject:[self createActor:actorDict ofClass:actorClass withResource:res named:name]];
	}	

	// add the joints
#if defined (FC_PHYSICS)
	// REMOVE
	NSArray* joints = [res.xmlData arrayForKeyPath:@"fcr.physics.joints.joint"];

	for(NSDictionary* jointDict in joints)
	{
		[self addJoint:jointDict];
	}
#endif

	NSArray* retArray = [NSArray arrayWithArray:newActors];
	return retArray;
}

-(id)createActor:(NSDictionary*)actorDict ofClass:(NSString *)actorClass withResource:(FCResource *)res named:(NSString*)name
{
	// get body
	
	NSString* bodyId = [actorDict valueForKey:@"body"];	
	NSArray* bodies = [res.xmlData arrayForKeyPath:@"fcr.physics.bodies.body"];
	
	// Find the body associated with this actor
	
	NSDictionary* bodyDict = nil;
	for(NSDictionary* body in bodies)
	{
		NSString* thisId = [body valueForKey:@"id"];
		
		if ([thisId isEqualToString:bodyId]) 
		{
			bodyDict = body;
			break;
		}
	}
	
	// get model

	NSString* modelId = [actorDict valueForKey:@"model"];
	NSArray* models = [res.xmlData arrayForKeyPath:@"fcr.models.model"];

	NSDictionary* modelDict = nil;
	for(NSDictionary* model in models)
	{
		NSString* thisId = [model valueForKey:@"modelId"];
		
		if ([thisId isEqualToString:modelId]) 
		{
			modelDict = model;
			break;
		}
	}

	// instantiate actor
	
	id actor = [self actorOfClass:NSClassFromString(actorClass)];
	
	actor = [actor initWithDictionary:actorDict body:bodyDict model:modelDict resource:res];

	// some more checks etc
	
	NSString* actorId = [actorDict valueForKey:@"id"];

	if (actorId) // id is optional
	{
//		id result = [_actorIdDictionary valueForKey:actorId];
//		
//		if (result == nil) {
//			[_actorIdDictionary setValue:[NSMutableSet setWithObject:actor] forKey:actorId];
//		} else {
//			FC_HALT;	// why should we allow non-unique id's ???
//			NSAssert([result isKindOfClass:[NSMutableSet class]], @"id dict does not have set in it");
//			NSMutableSet* set = (NSMutableSet*)result;
//			[set addObject:actor];
//		}
		[_actorIdDictionary setValue:actor forKey:actorId];
	}

	// add to class arrays dictionary
	
	if (![_classArraysDictionary valueForKey:actorClass]) 
	{
		NSMutableArray* classArray = [NSMutableArray array];
		[_classArraysDictionary setValue:classArray forKey:actorClass];
	}
	
	[[_classArraysDictionary valueForKey:actorClass] addObject:actor];

	// name
	
	if (name) {
		[_actorNameDictionary setValue:actor forKey:name];
		((FCActor*)actor).name = name;
	}
	
	return actor;
}

#if defined (FC_PHYSICS)
-(void)addJoint:(NSDictionary *)jointDict
{
	NSString* jointType = [jointDict valueForKey:@"type"];
	
	if ([jointType isEqualToString:@"distance"])	// Distance joint
	{
		NSString* bodyId = [jointDict valueForKey:@"bodyId"];
//		NSMutableSet* parentActorSet = [_actorIdDictionary valueForKey:bodyId];
		NSString* anchorId = [jointDict valueForKey:@"anchor"];
//		NSMutableSet* anchorActorSet = [_actorIdDictionary valueForKey:anchorId];
		
//		if (([parentActorSet count] == 1) && ([anchorActorSet count] == 1))
//		{
			FCActor* parentActor = [_actorIdDictionary valueForKey:bodyId];
			
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetX], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetX);
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetY], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetY);
			NSAssert1([jointDict valueForKey:kFCKeyJointOffsetX], @"Distance joint requires %@ element", kFCKeyJointOffsetX);
			NSAssert1([jointDict valueForKey:kFCKeyJointOffsetY], @"Distance joint requires %@ element", kFCKeyJointOffsetY);
			
			FCActor* anchorActor = [_actorIdDictionary valueForKey:anchorId];
			
			NSAssert1(anchorActor, @"nil anchor actor found '%@'", [jointDict valueForKey:kFCKeyJointAnchorId]);
			
			FCPhysics2DBody* anchorPhysicsBody = anchorActor.body2d;
			FCPhysics2DBody* parentPhysicsBody = parentActor.body2d;
			FC::Vector2f anchorOffset;
			anchorOffset.x = [[jointDict valueForKey:kFCKeyJointAnchorOffsetX] floatValue];
			anchorOffset.y = [[jointDict valueForKey:kFCKeyJointAnchorOffsetY] floatValue];
			
			FC::Vector2f offset;
			offset.x = [[jointDict valueForKey:kFCKeyJointOffsetX] floatValue];
			offset.y = [[jointDict valueForKey:kFCKeyJointOffsetY] floatValue];

			[parentPhysicsBody createDistanceJointWith:anchorPhysicsBody atOffset:offset anchorOffset:anchorOffset];			
//		} 
//		else
//		{
//			NSAssert(0, @"borked distance joint");
//		}
	} 
	else if ([jointType isEqualToString:@"revolute"])
	{
		NSString* bodyId = [jointDict valueForKey:@"bodyId"];
//		NSMutableSet* parentActorSet = [_actorIdDictionary valueForKey:bodyId];
		NSString* anchorId = [jointDict valueForKey:@"anchor"];
//		NSMutableSet* anchorActorSet = [_actorIdDictionary valueForKey:anchorId];
		
//		if (([parentActorSet count] == 1) && ([anchorActorSet count] == 1))
//		{
			FCActor* parentActor = [_actorIdDictionary valueForKey:bodyId];
			
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetX], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetX);
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetY], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetY);
			
			FCActor* anchorActor = [_actorIdDictionary valueForKey:anchorId];
			
			NSAssert1(anchorActor, @"nil anchor actor found '%@'", [jointDict valueForKey:kFCKeyJointAnchorId]);
			
			FCPhysics2DBody* anchorPhysicsBody = anchorActor.body2d;
			FCPhysics2DBody* parentPhysicsBody = parentActor.body2d;
			
			FC::Vector2f anchorOffset;
			anchorOffset.x = [[jointDict valueForKey:kFCKeyJointAnchorOffsetX] floatValue];
			anchorOffset.y = [[jointDict valueForKey:kFCKeyJointAnchorOffsetY] floatValue];

			float speed = kFCInvalidFloat;
			float torque = kFCInvalidFloat;
			float min = kFCInvalidFloat;
			float max = kFCInvalidFloat;
			
			if ([jointDict valueForKey:@"speed"]) {
				speed = [[jointDict valueForKey:@"speed"] floatValue];
			}
			if ([jointDict valueForKey:@"torque"]) {
				torque = [[jointDict valueForKey:@"torque"] floatValue];
			}
			if ([jointDict valueForKey:@"min"]) {
				min = [[jointDict valueForKey:@"min"] floatValue];
			}
			if ([jointDict valueForKey:@"max"]) {
				max = [[jointDict valueForKey:@"max"] floatValue];
			}
			
			[parentPhysicsBody createRevoluteJointWith:anchorPhysicsBody atOffset:anchorOffset motorSpeed:speed maxTorque:torque lowerAngle:min upperAngle:max];
//		} 
//		else
//		{
//			NSAssert(0, @"borked revolute joint");
//		}		
	}
	else if ([jointType isEqualToString:@"prismatic"])
	{
		NSString* bodyId = [jointDict valueForKey:@"bodyId"];
//		NSMutableSet* parentActorSet = [_actorIdDictionary valueForKey:bodyId];
		NSString* anchorId = [jointDict valueForKey:@"anchor"];
//		NSMutableSet* anchorActorSet = [_actorIdDictionary valueForKey:anchorId];
		
//		if (([parentActorSet count] == 1) && ([anchorActorSet count] == 1))
//		{
			FCActor* parentActor = [_actorIdDictionary valueForKey:bodyId];
			
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetX], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetX);
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetY], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetY);
			
			FCActor* anchorActor = [_actorIdDictionary valueForKey:anchorId];
			
			NSAssert1(anchorActor, @"nil anchor actor found '%@'", [jointDict valueForKey:kFCKeyJointAnchorId]);
			
			FCPhysics2DBody* anchorPhysicsBody = anchorActor.body2d;
			FCPhysics2DBody* parentPhysicsBody = parentActor.body2d;
			
			FC::Vector2f anchorOffset;
			anchorOffset.x = [[jointDict valueForKey:kFCKeyJointAnchorOffsetX] floatValue];
			anchorOffset.y = [[jointDict valueForKey:kFCKeyJointAnchorOffsetY] floatValue];
			
			float speed = kFCInvalidFloat;
			float force = kFCInvalidFloat;
			float min = kFCInvalidFloat;
			float max = kFCInvalidFloat;
			
			if ([jointDict valueForKey:@"speed"]) {
				speed = [[jointDict valueForKey:@"speed"] floatValue];
			}
			if ([jointDict valueForKey:@"force"]) {
				force = [[jointDict valueForKey:@"force"] floatValue];
			}
			if ([jointDict valueForKey:@"min"]) {
				min = [[jointDict valueForKey:@"min"] floatValue];
			}
			if ([jointDict valueForKey:@"max"]) {
				max = [[jointDict valueForKey:@"max"] floatValue];
			}
			
			// axis needs doing
			
			float angle = [[jointDict valueForKey:@"axis"] floatValue];
			
			FC::Vector2f axis( sin(angle), cos(angle) );
			
			[parentPhysicsBody createPrismaticJointWith:anchorPhysicsBody axis:axis motorSpeed:speed maxForce:force lowerTranslation:min upperTranslation:max];
//		} 
//		else
//		{
//			NSAssert(0, @"borked prismatic joint");
//		}
	}
	else if ([jointType isEqualToString:@"pulley"])
	{
		NSString* body1Id = [jointDict valueForKey:@"bodyId"];
//		NSMutableSet* body1ActorSet = [_actorIdDictionary valueForKey:body1Id];
		NSString* body2Id = [jointDict valueForKey:@"anchor2body"];
//		NSMutableSet* body2ActorSet = [_actorIdDictionary valueForKey:body2Id];
		
//		if (([body1ActorSet count] == 1) && ([body2ActorSet count] == 1))
//		{
			FCActor* body1Actor = [_actorIdDictionary valueForKey:body1Id];
			FCActor* body2Actor = [_actorIdDictionary valueForKey:body2Id];
			
			NSAssert([jointDict valueForKey:@"length1"], @"Pulley joint requires 'length1' element");
			NSAssert([jointDict valueForKey:@"length2"], @"Pulley joint requires 'length2' element");
			NSAssert([jointDict valueForKey:@"ground1OffsetX"], @"Pulley joint requires 'ground1OffsetX' element");
			NSAssert([jointDict valueForKey:@"ground1OffsetY"], @"Pulley joint requires 'ground1OffsetY' element");
			NSAssert([jointDict valueForKey:@"ground2OffsetX"], @"Pulley joint requires 'ground2OffsetX' element");
			NSAssert([jointDict valueForKey:@"ground2OffsetY"], @"Pulley joint requires 'ground2OffsetY' element");
			NSAssert([jointDict valueForKey:@"anchor1OffsetX"], @"Pulley joint requires 'anchor1OffsetX' element");
			NSAssert([jointDict valueForKey:@"anchor1OffsetY"], @"Pulley joint requires 'anchor1OffsetY' element");
			NSAssert([jointDict valueForKey:@"anchor2OffsetX"], @"Pulley joint requires 'anchor2OffsetX' element");
			NSAssert([jointDict valueForKey:@"anchor2OffsetY"], @"Pulley joint requires 'anchor2OffsetY' element");
						
			FCPhysics2DBody* body1PhysicsBody = body1Actor.body2d;
			FCPhysics2DBody* body2PhysicsBody = body2Actor.body2d;
			
			FC::Vector2f anchor1;
			anchor1.x = [[jointDict valueForKey:@"anchor1OffsetX"] floatValue];
			anchor1.y = [[jointDict valueForKey:@"anchor1OffsetY"] floatValue];
			
			FC::Vector2f anchor2;
			anchor1.x = [[jointDict valueForKey:@"anchor2OffsetX"] floatValue];
			anchor1.y = [[jointDict valueForKey:@"anchor2OffsetY"] floatValue];
			
			FC::Vector2f ground1;
			ground1.x = [[jointDict valueForKey:@"ground1OffsetX"] floatValue];
			ground1.y = [[jointDict valueForKey:@"ground1OffsetY"] floatValue];
			
			FC::Vector2f ground2;
			ground2.x = [[jointDict valueForKey:@"ground2OffsetX"] floatValue];
			ground2.y = [[jointDict valueForKey:@"ground2OffsetY"] floatValue];

			float length1 = [[jointDict valueForKey:@"length1"] floatValue];
			float length2 = [[jointDict valueForKey:@"length2"] floatValue];
			float ratio = [[jointDict valueForKey:@"ratio"] floatValue];
			
			[body1PhysicsBody createPulleyJointWith:body2PhysicsBody anchor1:anchor1 anchor2:anchor2 groundAnchor1:ground1 groundAnchor2:ground2 ratio:ratio maxLength1:length1 maxLength2:length2];
//		} 
//		else
//		{
//			NSAssert(0, @"borked prismatic joint");
//		}
	}
	else 
	{
		NSAssert1(0, @"unknown joint type %@", jointType);
	}
}
#endif

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
	if (((FCActor*)actor).Id) 
	{
		NSString* Id = ((FCActor*)actor).Id;
//		id actorSet = [_actorIdDictionary valueForKey:Id];
//		[actorSet removeObject:actor];
		[_actorIdDictionary removeObjectForKey:Id];
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
	
	if (actor.name) {
		[_actorNameDictionary removeObjectForKey:actor.name];
	}
}

-(NSArray*)getActorsOfClass:(NSString*)actorClass
{
	return [_classArraysDictionary valueForKey:actorClass];
}

-(id)actorWithId:(NSString *)Id
{
	return [_actorIdDictionary valueForKey:Id];
}

#pragma mark -
#pragma mark GameObjectLifetime methods

-(void)reset
{
	[self removeAllActors];
}

-(void)removeAllActors
{
	NSArray* actorsArray = [NSArray arrayWithArray:_allActorsArray];
	
	for (FCActor* actor in actorsArray)
	{
		[self removeActor:actor];
	}
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

-(FCActor*)actorAtPosition:(FC::Vector2f)pos
{
	FCActor* ret = nil;
	
	NSMutableArray* candidates = [NSMutableArray arrayWithCapacity:[_tapGestureActorsArray count]];
	
	// Find candidates using radius checks
	
	for( FCActor* actor in _tapGestureActorsArray )
	{
		FC::Vector2f actorPos = actor.position;
		if ([actor radius] >= FC::Distance(actorPos, pos)) 
		{
			[candidates addObject:actor];
		}
	}
	
	// do proper check by asking actor if pos is within bounds
	
	for( FCActor* actor in candidates )
	{
		if ([actor posWithinBounds:pos]) 
		{
			ret = actor;
			break;
		}
	}
	
	return ret;
}

@end



