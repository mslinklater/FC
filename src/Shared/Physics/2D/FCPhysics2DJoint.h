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

#ifndef CR1_FCPhysics2DJoint_h
#define CR1_FCPhysics2DJoint_h

#include <map>

#include "Shared/Core/Maths/FCMaths.h"
#include "Shared/Physics/2D/FCPhysics2DBody.h"

class FCPhysics2DJointCreateDef {
public:
	virtual ~FCPhysics2DJointCreateDef(){}
	
	FCPhysics2DBodyRef body1;
	FCPhysics2DBodyRef body2;
};

typedef std::shared_ptr<FCPhysics2DJointCreateDef> FCPhysics2DJointCreateDefRef;
typedef std::map<FCHandle,b2Joint*> FCPhysics2DJointMapByHandle;

//

class FCPhysics2DDistanceJointCreateDef : public FCPhysics2DJointCreateDef {
public:
	virtual ~FCPhysics2DDistanceJointCreateDef(){}
	FCVector2f pos1;
	FCVector2f pos2;
};

typedef std::shared_ptr<FCPhysics2DDistanceJointCreateDef> FCPhysics2DDistanceJointCreateDefRef;

//

class FCPhysics2DRevoluteJointCreateDef : public FCPhysics2DJointCreateDef {
public:
	virtual ~FCPhysics2DRevoluteJointCreateDef(){}
	FCVector2f pos;
};

typedef std::shared_ptr<FCPhysics2DRevoluteJointCreateDef> FCPhysics2DRevoluteJointCreateDefRef;

//

class FCPhysics2DPrismaticJointCreateDef : public FCPhysics2DJointCreateDef {
public:
	virtual ~FCPhysics2DPrismaticJointCreateDef(){}
	FCVector2f axis;
};

typedef std::shared_ptr<FCPhysics2DPrismaticJointCreateDef> FCPhysics2DPrismaticJointCreateDefRef;

//

class FCPhysics2DRopeJointCreateDef : public FCPhysics2DJointCreateDef {
public:
	virtual ~FCPhysics2DRopeJointCreateDef(){}
	FCVector2f bodyAnchor1;
	FCVector2f bodyAnchor2;
};

typedef std::shared_ptr<FCPhysics2DRopeJointCreateDef> FCPhysics2DRopeJointCreateDefRef;

//

class FCPhysics2DPulleyJointCreateDef : public FCPhysics2DJointCreateDef {
public:
	virtual ~FCPhysics2DPulleyJointCreateDef(){}
	FCVector2f bodyAnchor1;
	FCVector2f bodyAnchor2;
	FCVector2f groundAnchor1;
	FCVector2f groundAnchor2;
	float ratio;
};

typedef std::shared_ptr<FCPhysics2DPulleyJointCreateDef> FCPhysics2DPulleyJointCreateDefRef;

#endif

