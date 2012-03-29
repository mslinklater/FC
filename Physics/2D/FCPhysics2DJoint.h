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

#import <Foundation/Foundation.h>
#import "FCMaths.h"
#import "FCPhysics2DBody.h"

#pragma mark - FCPhysics2DJoint

@interface FCPhysics2DJoint : NSObject
@end

#pragma mark - FCPhysics2DJointCreateDef

@interface FCPhysics2DJointCreateDef : NSObject {
	FCPhysics2DBody* _body1;
	FCPhysics2DBody* _body2;
}
@property(nonatomic, strong) FCPhysics2DBody* body1;
@property(nonatomic, strong) FCPhysics2DBody* body2;
@end

#pragma mark - FCPhysics2DDistanceJointCreateDef

@interface FCPhysics2DDistanceJointCreateDef : FCPhysics2DJointCreateDef {
	FC::Vector2f _pos1;
	FC::Vector2f _pos2;
}
@property(nonatomic) FC::Vector2f pos1;
@property(nonatomic) FC::Vector2f pos2;
@end

#pragma mark - FCPhysics2DRevoluteJointCreateDef

@interface FCPhysics2DRevoluteJointCreateDef : FCPhysics2DJointCreateDef {
	FC::Vector2f	_pos;
}
@property(nonatomic) FC::Vector2f pos;
@end

#pragma mark - FCPhysics2DPrismaticJointCreateDef

@interface FCPhysics2DPrismaticJointCreateDef : FCPhysics2DJointCreateDef {
	FC::Vector2f	_axis;
}
@property(nonatomic) FC::Vector2f axis;
@end

#pragma mark - FCPhysics2DRopeJointCreateDef

@interface FCPhysics2DRopeJointCreateDef : FCPhysics2DJointCreateDef {
	FC::Vector2f	_bodyAnchor1;
	FC::Vector2f	_bodyAnchor2;
}
@property(nonatomic) FC::Vector2f bodyAnchor1;
@property(nonatomic) FC::Vector2f bodyAnchor2;
@end

#pragma mark - FCPhysics2DPulleyJointCreateDef

@interface FCPhysics2DPulleyJointCreateDef : FCPhysics2DJointCreateDef {
	FC::Vector2f	_bodyAnchor1;
	FC::Vector2f	_bodyAnchor2;
	FC::Vector2f	_groundAnchor1;
	FC::Vector2f	_groundAnchor2;
	float			_ratio;
}
@property(nonatomic) FC::Vector2f bodyAnchor1;
@property(nonatomic) FC::Vector2f bodyAnchor2;
@property(nonatomic) FC::Vector2f groundAnchor1;
@property(nonatomic) FC::Vector2f groundAnchor2;
@property(nonatomic) float ratio;
@end
