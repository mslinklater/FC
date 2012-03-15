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

#if defined (FC_PHYSICS)

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>

#import "FCCore.h"
#import "FCPhysics2DBody.h"
#import "FCPhysics2DBodyDef.h"
#import "FCPhysics2DJoint.h"
#import "FCPhysics2DContactListener.h"

@interface FCPhysics2D : NSObject <FCGameObjectUpdate> {
    b2World*				_world;
	b2Vec2					_gravity;
	NSMutableDictionary*	_joints;
	NSMutableDictionary*	_bodies;
	NSMutableDictionary*	_bodiesByName;
	FCPhysics2DContactListener*	_contactListener;
}
@property(nonatomic) b2World* world;
@property(nonatomic) b2Vec2 gravity;
@property(nonatomic, strong) NSMutableDictionary* joints;
@property(nonatomic, strong) NSMutableDictionary* bodies;
@property(nonatomic, readonly) FCPhysics2DContactListener* contactListener;

-(void)prepareForDealloc;

-(FCPhysics2DBody*)newBodyWithDef:(FCPhysics2DBodyDef*)def name:(NSString*)name actorHandle:(FCHandle)actorHandle;
-(void)destroyBody:(FCPhysics2DBody*)body;

-(FCPhysics2DBody*)bodyWithName:(NSString*)name;

-(FCHandle)createJoint:(FCPhysics2DJointCreateDef*)def;

-(void)setRevoluteJoint:(FCHandle)handle motorEnabled:(BOOL)enabled torque:(float)torque speed:(float)speed;
-(void)setRevoluteJoint:(FCHandle)handle limitsEnabled:(BOOL)enabled min:(float)min max:(float)max;

-(void)setPrismaticJoint:(FCHandle)handle motorEnabled:(BOOL)enabled force:(float)force speed:(float)speed;
-(void)setPrismaticJoint:(FCHandle)handle limitsEnabled:(BOOL)enabled min:(float)min max:(float)max;

@end

#endif // defined(FC_PHYSICS)
