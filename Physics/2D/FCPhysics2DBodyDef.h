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

#include "Shared/Core/FCXML.h"

class b2World;

@interface FCPhysics2DBodyDef : NSObject 
{
	float			_angle;
	BOOL			_isStatic;
	BOOL			_canSleep;
	float			_linearDamping;
	FCXMLNode		_shapeXML;
	b2World*		_world;
	id __weak		_actor;	// deprecate
	FCHandle		_hActor;
	FC::Vector2f	_position;
}
@property(nonatomic, readonly, strong) NSString* Id;
@property(nonatomic) float angle;
@property(nonatomic) BOOL isStatic;
@property(nonatomic) BOOL canSleep;
@property(nonatomic) float linearDamping;
@property(nonatomic) FCXMLNode shapeXML;
@property(nonatomic) b2World* world;
@property(nonatomic, weak) id actor;
@property(nonatomic) FCHandle hActor;
@property(nonatomic) FC::Vector2f position;

+(FCPhysics2DBodyDef*)defaultDef;

-(NSString*)description;
@end

#endif // defined(FC_PHYSICS)