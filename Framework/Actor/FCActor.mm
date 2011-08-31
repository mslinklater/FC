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

#import "FCActor.h"
#import "FCRenderer.h"
#import "FCPhysics.h"
#import "FCActorSystem.h"
#import "FCResource.h"

@interface FCActor(hidden)
@end

@implementation FCActor

@synthesize createDef = _createDef;
@synthesize Id = _id;

#pragma mark - Initializers

-(id)initWithDictionary:(NSDictionary*)dictionary body:(NSDictionary*)bodyDict model:(NSDictionary*)modelDict resource:(FCResource*)res
{
	self = [super init];
	if (self) 
	{	
		_createDef = [dictionary retain];
		_id = [[self.createDef valueForKey:kFCKeyId] retain];
				
		if (bodyDict) 
		{
			FCPhysics2DBodyDef* bodyDef = [FCPhysics2DBodyDef defaultDef];
			
			FC::Vector2f pos;
			pos.Zero();
			
			pos.x += [[dictionary valueForKey:kFCKeyOffsetX] floatValue];
			pos.y += [[dictionary valueForKey:kFCKeyOffsetY] floatValue];
			
			[bodyDef setPosition:pos];
			bodyDef.angle = [[dictionary valueForKey:@"rotation"] floatValue];
			bodyDef.actor = self;
			
			if ([[dictionary valueForKey:kFCKeyDynamic] isEqualToString:@"yes"]) {
				bodyDef.isStatic = NO;
			} else {
				bodyDef.isStatic = YES;
			}
			
			bodyDef.canSleep = NO;
			bodyDef.shapeDef = bodyDict;
			
			mBody2d = [[[FCPhysics instance] twoD] newBodyWithDef:bodyDef];
		}
		
		// now create a model
		
//		if (modelDict) 
		if ( 0 )
		{
			mModel = [[FCModel alloc] initWithModel:modelDict resource:res];
		}
		else
		{
			if (bodyDict) 
			{
				// physics but no model so build a physics mode
				
				mModel = [[FCModel alloc] initWithPhysicsBody:bodyDict];
			}
		}
	}
	return self;
}

-(void)dealloc
{
	[mBody2d release];
	[mModel release];
	
	[_createDef release], _createDef = nil;
	[_id release], _id = nil;
	
	[super dealloc];
}

#pragma mark - Joints

-(void)addJoints:(id)jointsDef
{
//	// Could move this up the code hierarchy possibly ???
//
//	NSArray* jointsArray;
//
//	if ([jointsDef isKindOfClass:[NSDictionary class]]) {
//		jointsArray = [NSArray arrayWithObject:jointsDef];
//	} else {
//		jointsArray = [NSArray arrayWithArray:jointsDef];
//	}
//
//	for(NSDictionary* jointDict in jointsArray)
//	{
//		else if ([[jointDict valueForKey:kFCKeyJointType] isEqualToString:kFCKeyJointTypePrismatic]) // Prismatic joint
//		{
//			NSAssert1([jointDict valueForKey:kFCKeyJointAxisX], @"Prismatic joint requires %@ element", kFCKeyJointAxisX);
//			NSAssert1([jointDict valueForKey:kFCKeyJointAxisY], @"Prismatic joint requires %@ element", kFCKeyJointAxisY);
//			
//			FCActor* anchorActor = [[FCActorSystem instance] actorWithId:[jointDict valueForKey:kFCKeyJointAnchorId]];			
//			NSAssert1(anchorActor, @"nil anchor actor found '%@'", [jointDict valueForKey:kFCKeyJointAnchorId]);
//			FCPhysics2DBody* anchorPhysicsBody = [anchorActor getPhysics2DBody];
//
//			FC::Vector2f axis;
//			axis.x = [[jointDict valueForKey:kFCKeyJointAxisX] floatValue];
//			axis.y = [[jointDict valueForKey:kFCKeyJointAxisY] floatValue];
//
//			float motorSpeed = kFCInvalidFloat;
//			float maxForce = kFCInvalidFloat;
//			float lowerTrans = kFCInvalidFloat;
//			float upperTrans = kFCInvalidFloat;
//			
//			if (([jointDict valueForKey:kFCKeyJointLowerTranslation]) && ([jointDict valueForKey:kFCKeyJointUpperTranslation])) {
//				lowerTrans = [[jointDict valueForKey:kFCKeyJointLowerTranslation] floatValue];
//				upperTrans = [[jointDict valueForKey:kFCKeyJointUpperTranslation] floatValue];
//			}
//
//			if (([jointDict valueForKey:kFCKeyJointMotorSpeed]) && ([jointDict valueForKey:kFCKeyJointMaxMotorForce])) {
//				motorSpeed = [[jointDict valueForKey:kFCKeyJointMotorSpeed] floatValue];
//				maxForce = [[jointDict valueForKey:kFCKeyJointMaxMotorForce] floatValue];
//			}
//
//			[mBody2d createPrismaticJointWith:anchorPhysicsBody axis:axis motorSpeed:motorSpeed maxForce:maxForce lowerTranslation:lowerTrans upperTranslation:upperTrans];
//		}
//		else if ([[jointDict valueForKey:kFCKeyJointType] isEqualToString:kFCKeyJointTypePulley]) // Pully joint
//		{
////			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetX], @"Pulley joint requires %@ element", kFCKeyJointAnchorOffsetX);
////			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorOffsetY], @"Pulley joint requires %@ element", kFCKeyJointAnchorOffsetY);
////			NSAssert1([jointDict valueForKey:kFCKeyJointOffsetX], @"Pulley joint requires %@ element", kFCKeyJointOffsetX);
////			NSAssert1([jointDict valueForKey:kFCKeyJointOffsetY], @"Pulley joint requires %@ element", kFCKeyJointOffsetY);
//			NSAssert1([jointDict valueForKey:kFCKeyJointGroundX], @"Pulley joint requires %@ element", kFCKeyJointGroundX);
//			NSAssert1([jointDict valueForKey:kFCKeyJointGroundY], @"Pulley joint requires %@ element", kFCKeyJointGroundY);
//			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorGroundX], @"Pulley joint requires %@ element", kFCKeyJointAnchorGroundX);
//			NSAssert1([jointDict valueForKey:kFCKeyJointAnchorGroundY], @"Pulley joint requires %@ element", kFCKeyJointAnchorGroundY);
//			NSAssert1([jointDict valueForKey:kFCKeyJointRatio], @"Pulley joint requires %@ element", kFCKeyJointRatio);
//			
//			FCActor* anchorActor = [[FCActorSystem instance] actorWithId:[jointDict valueForKey:kFCKeyJointAnchorId]];			
//			NSAssert1(anchorActor, @"nil anchor actor found '%@'", [jointDict valueForKey:kFCKeyJointAnchorId]);			
//			FCPhysics2DBody* anchorPhysicsBody = [anchorActor getPhysics2DBody];
//			
//			FC::Vector2f anchor1;
//			FC::Vector2f anchor2;
//			FC::Vector2f ground1;
//			FC::Vector2f ground2;
//			
//			anchor1.x = [[jointDict valueForKey:kFCKeyJointOffsetX] floatValue];
//			anchor1.y = [[jointDict valueForKey:kFCKeyJointOffsetY] floatValue];
//			anchor2.x = [[jointDict valueForKey:kFCKeyJointAnchorOffsetX] floatValue];
//			anchor2.y = [[jointDict valueForKey:kFCKeyJointAnchorOffsetY] floatValue];
//			ground1.x = [[jointDict valueForKey:kFCKeyJointGroundX] floatValue];
//			ground1.y = [[jointDict valueForKey:kFCKeyJointGroundY] floatValue];
//			ground2.x = [[jointDict valueForKey:kFCKeyJointAnchorGroundX] floatValue];
//			ground2.y = [[jointDict valueForKey:kFCKeyJointAnchorGroundY] floatValue];
//			
//			float ratio = [[jointDict valueForKey:kFCKeyJointRatio] floatValue];
//			
//			float maxLength1 = kFCInvalidFloat;
//			float maxLength2 = kFCInvalidFloat;
//
//			if ([jointDict valueForKey:kFCKeyJointMaxLength1]) {
//				maxLength1 = [[jointDict valueForKey:kFCKeyJointMaxLength1] floatValue];
//			}
//			if ([jointDict valueForKey:kFCKeyJointMaxLength2]) {
//				maxLength2 = [[jointDict valueForKey:kFCKeyJointMaxLength2] floatValue];
//			}
//			
//			[mBody2d createPulleyJointWith:anchorPhysicsBody anchor1:anchor1 anchor2:anchor2 groundAnchor1:ground1 groundAnchor2:ground2 ratio:ratio maxLength1:maxLength1 maxLength2:maxLength2];
//		}
//	}
}

#pragma mark - Getters

-(FC::Vector2f)getCenter
{
	return [mBody2d position];
}

-(FCPhysics2DBody*)getPhysics2DBody
{
	return mBody2d;
}

#pragma mark - Setters

-(void)setPosition:(FC::Vector2f)newPosition
{
	[mBody2d setPosition:newPosition];
}

-(void)applyImpulse:(FC::Vector2f)impulse atWorldPos:(FC::Vector2f)pos
{
	[mBody2d applyImpulse:impulse atWorldPos:pos];
}

-(BOOL)needsUpdate
{
	return NO;
}

-(BOOL)needsRender
{
	return NO;
}

-(BOOL)respondsToTapGesture
{
	return NO;
}

-(void)update:(float)gameTime;
{
	if( mBody2d )
	{
		FC::Vector2f pos = [mBody2d position ];
		float rot = [mBody2d rotation];
		
		if( mModel )
		{
			[mModel setRotation:rot];
			[mModel setPosition:FC::Vector3f(pos.x, pos.y, 0.0f)];					
		}
	}
}

-(void)render
{
	[mModel render];
}

-(float)radius
{
	return 0.0f;
}

-(BOOL)posWithinBounds:(FC::Vector2f)pos
{
	return NO;
}

@end

#endif // TARGET_OS_IPHONE
