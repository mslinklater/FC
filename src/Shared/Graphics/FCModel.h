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

#ifndef FCModel_h
#define FCModel_h

#include "FCGraphics.h"

#include "Shared/Core/FCCore.h"
#include "Shared/Core/FCXML.h"
#include "Shared/Core/Resources/FCResource.h"

class IFCModel {
public:
	IFCModel(){}
	virtual ~IFCModel(){}
	
	virtual void InitWithModel( FCXMLNode modelXML, FCResourceRef resource ) = 0;
	virtual void InitWithPhysics( FCXMLNode physicsXML, FCColor4f& color ) = 0;
	virtual void SetDebugMeshColor( FCColor4f& color ) = 0;
	virtual void SetRotation( float rot ) = 0;
	virtual void SetPosition( FCVector3f& pos ) = 0;
};

typedef FCSharedPtr<IFCModel>	FCModelRef;
typedef std::vector<FCModelRef>		FCModelRefVec;
typedef FCModelRefVec::iterator		FCModelRefVecIter;

extern FCModelRef plt_FCModel_Create();

#endif
