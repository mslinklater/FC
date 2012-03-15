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

#if defined(FC_PHYSICS)

#import <Foundation/Foundation.h>

#import "FCCore.h"
#import "FCPhysicsTypes.h"

class b2World;
class b2Body;

@class FCPhysics2DBodyDef;

@interface FCPhysics2DBody : NSObject <FCPhysicsBody> 
{
	NSString*		_Id;
	NSString*		_name;
	b2World*		_world;
	b2Body*			_body;
	FCHandle		_handle;
}
@property(nonatomic, strong) NSString* Id;
@property(nonatomic, strong) NSString* name;
@property(nonatomic) b2World* world;
@property(nonatomic, readonly) b2Body* body;
@property(nonatomic) FCHandle handle;

@property(nonatomic, readonly) float rotation;
@property(nonatomic) FC::Vector3f position;
@property(nonatomic) float angularVelocity;

-(id)initWithDef:(FCPhysics2DBodyDef*)def;

// turn these into a property
-(FC::Vector2f)linearVelocity;	
-(void)setLinearVelocity:(FC::Vector2f)newVel;

-(void)applyImpulse:(FC::Vector2f)impulse atWorldPos:(FC::Vector2f)pos;
//-(void)createPulleyJointWith:(FCPhysics2DBody*)otherBody anchor1:(FC::Vector2f)anchor1 anchor2:(FC::Vector2f)anchor2 groundAnchor1:(FC::Vector2f)ground1 groundAnchor2:(FC::Vector2f)ground2 ratio:(float)ratio maxLength1:(float)maxLength1 maxLength2:(float)maxLength2;
@end

#endif // defined(FC_PHYSICS)
