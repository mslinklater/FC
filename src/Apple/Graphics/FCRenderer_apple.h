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

/* TODO:
		Add perf metrics
 */

#ifndef FCRENDERER_APPLE_H
#define FCRENDERER_APPLE_H

#import <Foundation/Foundation.h>
#import "FCTextureManager_apple.h"

#include "FCActor.h"
#include "Shared/Graphics/FCRenderer.h"

@class FCTextureManager_apple;

@interface FCRenderer_apple : NSObject {
	NSString*		_name;
	NSMutableArray* _models;
	NSMutableArray* _meshes;
	FCActorVec		_gatherList;
	FCTextureManager_apple* _textureManager;
}
@property(nonatomic, strong, readonly) NSString* name;
@property(nonatomic, strong, readonly) NSMutableArray* models;
@property(nonatomic, strong, readonly) NSMutableArray* meshes;
@property(nonatomic, readonly) FCActorVec gatherList;
@property(nonatomic, strong) FCTextureManager_apple* textureManager;

-(id)initWithName:(NSString*)name;
-(void)render;

-(void)addToGatherList:(FCActorPtr)obj;
-(void)removeFromGatherList:(FCActorPtr)obj;

@end

//-----------------------------------------------------------------

class FCRendererProxy : public IFCRenderer
{
public:
	FCRendererProxy( std::string name )
	: IFCRenderer(name)
	{
		renderer = [[FCRenderer_apple alloc] initWithName:[NSString stringWithUTF8String:name.c_str()]];
	}
	
	virtual ~FCRendererProxy()
	{
		renderer = nil;
	}
	
	void Init( std::string name )
	{
		FC_HALT;
	}
	
	void SetTextureManager( IFCTextureManager* pTextureManager )
	{
		FCTextureManagerProxy* realTM = reinterpret_cast<FCTextureManagerProxy*>(pTextureManager);
		[renderer setTextureManager:realTM->textureManager];
	}
	
	void Render( void )
	{
		[renderer render];
	}
	
	void AddToGatherList( FCActorPtr actor )
	{
		[renderer addToGatherList:actor];
	}
	
	void RemoveFromGatherList( FCActorPtr actor )
	{
		[renderer removeFromGatherList:actor];
	}
	
private:
	FCRenderer_apple*	renderer;
};

#endif // define FCRENDERER_APPLE_H
