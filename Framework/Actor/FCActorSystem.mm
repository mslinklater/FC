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

#if TARGET_OS_IPHONE

#import "FCActorSystem.h"
#import "FCActor.h"
#import "FCPhysics.h"
#import "FCXMLData.h"
#import "FCResource.h"

@interface FCActorSystem(hidden)
//-(id)createActorOfClass:(NSString*)actorClass withDict:(NSDictionary*)dict bodies:(NSArray*)bodies models:(NSArray*)models;
-(id)createActor:(NSDictionary*)actorDict ofClass:(NSString*)actorClass withResource:(FCResource*)res;
-(void)addJoint:(NSDictionary*)jointDict;
@end

@implementation FCActorSystem

#pragma mark - FCSingleton protocol

+(id)instance
{
	static FCActorSystem* pInstance;
	
	if (!pInstance) {
		pInstance = [[FCActorSystem alloc] init];
	}
	return pInstance;
}

#pragma mark - Object Lifetime

-(id)init
{
	self = [super init];
	if (self) 
	{
		mAllActorsArray = [[NSMutableArray alloc] init];
		mUpdateActorsArray = [[NSMutableArray alloc] init];
		mRenderActorsArray = [[NSMutableArray alloc] init];
		mTapGestureActorsArray = [[NSMutableArray alloc] init];
		mDeleteList = [[NSMutableArray alloc] init];
		mClassArraysDictionary = [[NSMutableDictionary alloc] init];
		mActorIdDictionary = [[NSMutableDictionary alloc] init];
	}

	return self;
}

#pragma mark - New FCR Based methods

-(NSArray*)createActorsOfClass:(NSString *)actorClass withResource:(FCResource *)res
{
	NSMutableArray* newActors = [NSMutableArray array];

	NSArray* actors = [res.xmlData arrayForKeyPath:@"fcr.scene.actor"];
	
	// create actors
	
	for(NSDictionary* actorDict in actors)
	{
		[newActors addObject:[self createActor:actorDict ofClass:actorClass withResource:res]];
	}	

	// add the joints

	NSArray* joints = [res.xmlData arrayForKeyPath:@"fcr.physics.joints.joint"];

	for(NSDictionary* jointDict in joints)
	{
		[self addJoint:jointDict];
	}

	NSArray* retArray = [NSArray arrayWithArray:newActors];
	return retArray;
}

-(id)createActor:(NSDictionary*)actorDict ofClass:(NSString *)actorClass withResource:(FCResource *)res
{
	// get body
	
	NSString* bodyId = [actorDict valueForKey:@"body"];	
	NSArray* bodies = [res.xmlData arrayForKeyPath:@"fcr.physics.bodies.body"];
	
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
	
	id actor = [[self actorOfClass:NSClassFromString(actorClass)] retain];
	
	actor = [actor initWithDictionary:actorDict body:bodyDict model:modelDict resource:res];

	// some more checks etc
	
	NSString* actorId = [actorDict valueForKey:@"id"];

	if (actorId) // id is optional
	{
		id result = [mActorIdDictionary valueForKey:actorId];
		
		if (result == nil) {
			[mActorIdDictionary setValue:[NSMutableSet setWithObject:actor] forKey:actorId];
		} else {
			NSAssert([result isKindOfClass:[NSMutableSet class]], @"id dict does not have set in it");
			NSMutableSet* set = (NSMutableSet*)result;
			[set addObject:actor];
		}
	}

	// add to class arrays dictionary
	
	if (![mClassArraysDictionary valueForKey:actorClass]) 
	{
		NSMutableArray* classArray = [NSMutableArray array];
		[mClassArraysDictionary setValue:classArray forKey:actorClass];
	}
	
	[[mClassArraysDictionary valueForKey:actorClass] addObject:actor];

	return [actor autorelease];
}

-(void)addJoint:(NSDictionary *)jointDict
{
	NSString* jointType = [jointDict valueForKey:@"type"];
	
	if ([jointType isEqualToString:@"distance"])	// Distance joint
	{
		NSString* bodyId = [jointDict valueForKey:@"bodyId"];
		NSMutableSet* parentActorSet = [mActorIdDictionary valueForKey:bodyId];
		NSString* anchorId = [jointDict valueForKey:@"anchor"];
		NSMutableSet* anchorActorSet = [mActorIdDictionary valueForKey:anchorId];
		
		if (([parentActorSet count] == 1) && ([anchorActorSet count] == 1))
		{
			FCActor* parentActor = [parentActorSet anyObject];
			
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetX], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetX);
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetY], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetY);
			NSAssert1([jointDict valueForKey:kFCKeyJointOffsetX], @"Distance joint requires %@ element", kFCKeyJointOffsetX);
			NSAssert1([jointDict valueForKey:kFCKeyJointOffsetY], @"Distance joint requires %@ element", kFCKeyJointOffsetY);
			
			FCActor* anchorActor = [anchorActorSet anyObject];
			
			NSAssert1(anchorActor, @"nil anchor actor found '%@'", [jointDict valueForKey:kFCKeyJointAnchorId]);
			
			FCPhysics2DBody* anchorPhysicsBody = [anchorActor getPhysics2DBody];
			FCPhysics2DBody* parentPhysicsBody = [parentActor getPhysics2DBody];
			FC::Vector2f anchorOffset;
			anchorOffset.x = [[jointDict valueForKey:kFCKeyJointAnchorOffsetX] floatValue];
			anchorOffset.y = [[jointDict valueForKey:kFCKeyJointAnchorOffsetY] floatValue];
			
			FC::Vector2f offset;
			offset.x = [[jointDict valueForKey:kFCKeyJointOffsetX] floatValue];
			offset.y = [[jointDict valueForKey:kFCKeyJointOffsetY] floatValue];

			[parentPhysicsBody createDistanceJointWith:anchorPhysicsBody atOffset:offset anchorOffset:anchorOffset];			
		} 
		else
		{
			NSAssert(0, @"borked distance joint");
		}
	} 
	else if ([jointType isEqualToString:@"revolute"])
	{
		NSString* bodyId = [jointDict valueForKey:@"bodyId"];
		NSMutableSet* parentActorSet = [mActorIdDictionary valueForKey:bodyId];
		NSString* anchorId = [jointDict valueForKey:@"anchor"];
		NSMutableSet* anchorActorSet = [mActorIdDictionary valueForKey:anchorId];
		
		if (([parentActorSet count] == 1) && ([anchorActorSet count] == 1))
		{
			FCActor* parentActor = [parentActorSet anyObject];
			
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetX], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetX);
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetY], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetY);
			
			FCActor* anchorActor = [anchorActorSet anyObject];
			
			NSAssert1(anchorActor, @"nil anchor actor found '%@'", [jointDict valueForKey:kFCKeyJointAnchorId]);
			
			FCPhysics2DBody* anchorPhysicsBody = [anchorActor getPhysics2DBody];
			FCPhysics2DBody* parentPhysicsBody = [parentActor getPhysics2DBody];
			
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
		} 
		else
		{
			NSAssert(0, @"borked revolute joint");
		}		
	}
	else if ([jointType isEqualToString:@"prismatic"])
	{
		NSString* bodyId = [jointDict valueForKey:@"bodyId"];
		NSMutableSet* parentActorSet = [mActorIdDictionary valueForKey:bodyId];
		NSString* anchorId = [jointDict valueForKey:@"anchor"];
		NSMutableSet* anchorActorSet = [mActorIdDictionary valueForKey:anchorId];
		
		if (([parentActorSet count] == 1) && ([anchorActorSet count] == 1))
		{
			FCActor* parentActor = [parentActorSet anyObject];
			
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetX], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetX);
			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetY], @"Distance joint requires %@ element", kFCKeyJointAnchorOffsetY);
			
			FCActor* anchorActor = [anchorActorSet anyObject];
			
			NSAssert1(anchorActor, @"nil anchor actor found '%@'", [jointDict valueForKey:kFCKeyJointAnchorId]);
			
			FCPhysics2DBody* anchorPhysicsBody = [anchorActor getPhysics2DBody];
			FCPhysics2DBody* parentPhysicsBody = [parentActor getPhysics2DBody];
			
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
		} 
		else
		{
			NSAssert(0, @"borked prismatic joint");
		}
	}
	else if ([jointType isEqualToString:@"pulley"])
	{
		NSString* body1Id = [jointDict valueForKey:@"bodyId"];
		NSMutableSet* body1ActorSet = [mActorIdDictionary valueForKey:body1Id];
		NSString* body2Id = [jointDict valueForKey:@"anchor2body"];
		NSMutableSet* body2ActorSet = [mActorIdDictionary valueForKey:body2Id];
		
		if (([body1ActorSet count] == 1) && ([body2ActorSet count] == 1))
		{
			FCActor* body1Actor = [body1ActorSet anyObject];
			FCActor* body2Actor = [body2ActorSet anyObject];
			
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
						
			FCPhysics2DBody* body1PhysicsBody = [body1Actor getPhysics2DBody];
			FCPhysics2DBody* body2PhysicsBody = [body2Actor getPhysics2DBody];
			
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
		} 
		else
		{
			NSAssert(0, @"borked prismatic joint");
		}
	}
	else 
	{
		NSAssert1(0, @"unknown joint type %@", jointType);
	}
}

#pragma mark - Old stuff
#pragma mark -

-(id)actorOfClass:(Class)actorClass
{
	if(!actorClass)
	{
		UIAlertView *errorView = [[[UIAlertView alloc] initWithTitle:@"ERROR - FCActorSystem actorOfClass" message:@"nil actorClass" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[errorView show];
		return nil;
	}
	
	id newActor = [actorClass alloc];
	[mAllActorsArray addObject:newActor];

	if ([newActor needsUpdate]) {
		[mUpdateActorsArray addObject:newActor];
	}
	
	if ([newActor needsRender]) {
		[mRenderActorsArray addObject:newActor];
	}

	if ([newActor respondsToTapGesture]) {
		[mTapGestureActorsArray addObject:newActor];
	}

	return [newActor autorelease];
}

-(void)addToDeleteArray:(id)actor
{
	[mDeleteList addObject:actor];
}

-(void)removeActor:(id)actor
{
	if (((FCActor*)actor).Id) 
	{
		NSString* Id = ((FCActor*)actor).Id;
		NSMutableSet* actorSet = [mActorIdDictionary valueForKey:Id];
		[actorSet removeObject:actor];
	}

	if ([actor needsUpdate]) {
		[mUpdateActorsArray removeObject:actor];
	}

	if ([actor needsRender]) {
		[mRenderActorsArray removeObject:actor];
	}

	if ([actor respondsToTapGesture]) {
		[mTapGestureActorsArray removeObject:actor];
	}

	[mAllActorsArray removeObject:actor];
	
	[[mClassArraysDictionary valueForKey:NSStringFromClass([actor class])] removeObject:actor];	
}

-(NSArray*)getActorsOfClass:(NSString*)actorClass
{
	return [mClassArraysDictionary valueForKey:actorClass];
}

-(NSMutableSet*)actorsWithId:(NSString *)Id
{
	return [mActorIdDictionary valueForKey:Id];
}

#pragma mark -
#pragma mark GameObjectLifetime methods

-(void)reset
{
	[self removeAllActors];
}

-(void)destroy
{
	[self removeAllActors];
}

-(void)removeAllActors
{
	NSArray* actorsArray = [NSArray arrayWithArray:mAllActorsArray];
	
	for (FCActor* actor in actorsArray)
	{
		[self removeActor:actor];
	}
}

#pragma mark - GameObjectUpdate methods

-(void)update:(float)realTime gameTime:(float)gameTime
{	
	// remove actors on delete list
	
	for( FCActor* deleteActor in mDeleteList )
	{
		[self removeActor:deleteActor];
	}

	[mDeleteList removeAllObjects];
	
	// update active actors
	
	for( FCActor* actor in mUpdateActorsArray )
	{
		[actor update:gameTime];
	}
}

-(NSArray*)getUpdateActors
{
	return mUpdateActorsArray;
}

#pragma mark - GameObjectRender methods

-(NSArray*)renderGather
{
	return mRenderActorsArray;
}

-(FCActor*)actorAtPosition:(FC::Vector2f)pos
{
	FCActor* ret = nil;
	
	NSMutableArray* candidates = [NSMutableArray arrayWithCapacity:[mTapGestureActorsArray count]];
	
	// Find candidates using radius checks
	
	for( FCActor* actor in mTapGestureActorsArray )
	{
		FC::Vector2f actorPos = [actor getCenter];
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

#endif // TARGET_OS_IPHONE

