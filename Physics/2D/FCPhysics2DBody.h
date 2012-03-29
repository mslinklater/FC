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
	b2Body*			_b2Body;
	FCHandle		_handle;
}

@property(nonatomic, strong) NSString* Id;
@property(nonatomic, strong) NSString* name;
@property(nonatomic) b2World* world;
@property(nonatomic, readonly) b2Body* b2Body;
@property(nonatomic) FCHandle handle;

@property(nonatomic, readonly) float rotation;
@property(nonatomic) FC::Vector3f position;
@property(nonatomic) float angularVelocity;
@property(nonatomic) FC::Vector2f linearVelocity;

-(id)initWithDef:(FCPhysics2DBodyDef*)def;

-(void)applyImpulse:(FC::Vector2f)impulse atWorldPos:(FC::Vector2f)pos;
@end

#endif // defined(FC_PHYSICS)
