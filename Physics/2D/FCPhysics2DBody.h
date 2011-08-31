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

#import <Foundation/Foundation.h>
#import "FCKeys.h"
#import "FCMaths.h"

class b2World;
class b2Body;
@class FCPhysics2DBodyDef;

@interface FCPhysics2DBody : NSObject {
@private
	b2World* pWorld;
	b2Body* pBody;
}

-(id)initWithDef:(FCPhysics2DBodyDef*)def;

-(FC::Vector2f)position;
-(void)setPosition:(FC::Vector2f)pos;

-(FC::Vector2f)linearVelocity;
-(void)setLinearVelocity:(FC::Vector2f)newVel;

-(b2Body*)b2Body;

-(void)applyImpulse:(FC::Vector2f)impulse atWorldPos:(FC::Vector2f)pos;

-(float)rotation;

-(void)createRevoluteJointWith:(FCPhysics2DBody*)anchorBody atOffset:(FC::Vector2f)anchorOffset motorSpeed:(float)motorSpeed maxTorque:(float)maxToque lowerAngle:(float)lower upperAngle:(float)upper;
-(void)createDistanceJointWith:(FCPhysics2DBody*)anchorBody atOffset:(FC::Vector2f)offset anchorOffset:(FC::Vector2f)anchorOffset;
-(void)createPrismaticJointWith:(FCPhysics2DBody*)anchorBody axis:(FC::Vector2f)axis motorSpeed:(float)motorSpeed maxForce:(float)maxForce lowerTranslation:(float)lower upperTranslation:(float)upper;
-(void)createPulleyJointWith:(FCPhysics2DBody*)otherBody anchor1:(FC::Vector2f)anchor1 anchor2:(FC::Vector2f)anchor2 groundAnchor1:(FC::Vector2f)ground1 groundAnchor2:(FC::Vector2f)ground2 ratio:(float)ratio maxLength1:(float)maxLength1 maxLength2:(float)maxLength2;
@end

#endif // TARGET_OS_IPHONE
