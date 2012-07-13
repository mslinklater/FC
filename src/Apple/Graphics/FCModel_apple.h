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

#if 0

#if defined(FC_GRAPHICS)

#import <Foundation/Foundation.h>

#import "FCCore.h"

#include "Shared/Core/FCXML.h"
#include "Shared/Core/Resources/FCResource.h"

#include "Shared/Graphics/FCModel.h"

@class FCModel_apple;

//----------------------------------------------


@interface FCModel_apple : NSObject {	
	NSMutableArray* _meshes;
	FCVector3f _position;
	float _rotation;
}

@property(nonatomic, strong) NSMutableArray* meshes;
@property(nonatomic) FCVector3f position;
@property(nonatomic) float rotation;

-(id)initWithModel:(FCXMLNode)modelXML resource:(FCResourcePtr)res;
-(id)initWithPhysicsBody:(FCXMLNode)bodyXML color:(FCColor4f*)color;// actorXOffset:(float)actorX actorYOffset:(float)actorY;
-(void)setDebugMeshColor:(FCColor4f)color;
@end

//---------------------------------------------- Proxy

class FCModelProxy : public IFCModel {
public:
	FCModelProxy()
	{
	}
	virtual ~FCModelProxy()
	{
		model = nil;
	}
	
	FCModel_apple*	model;
	
	void InitWithModel( FCXMLNode modelXML, FCResourcePtr resource )
	{
		model = [[FCModel_apple alloc] initWithModel:modelXML resource:resource];
	}
	
	void InitWithPhysics( FCXMLNode physicsXML, FCColor4f* pColor )
	{
		model = [[FCModel_apple alloc] initWithPhysicsBody:physicsXML color:pColor];
	}
	
	void SetDebugMeshColor( FCColor4f* pColor)
	{
		[model setDebugMeshColor:*pColor];
	}
	
	void SetRotation( float rot )
	{
		[model setRotation:rot];
	}
	
	void SetPosition( FCVector3f* pPos )
	{
		[model setPosition:*pPos];
	}
};

//----------------------------------------------

#endif // defined(FC_GRAPHICS)

#endif
