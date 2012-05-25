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

#if defined(FC_GRAPHICS)

#import "FCCore.h"
#import "FCRenderer_apple.h"
//#import "FCAppContext.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FCModel_apple.h"
#import "FCShaderManager_apple.h"
#import "FCTextureManager_apple.h"
#import "FCLua.h"
#import "FCActorSystem.h"
#import "FCMesh_apple.h"

static NSMutableDictionary* s_renderers;
static FCRenderer_apple* s_currentLuaTarget;

// set current renderer

static int lua_SetCurrentRenderer( lua_State* _state )
{
	FC_LUA_ASSERT_NUMPARAMS(1);
	FC_LUA_ASSERT_TYPE(1, LUA_TSTRING);

	FCRenderer_apple* rend = [s_renderers valueForKey:[NSString stringWithUTF8String:lua_tostring(_state, 1)]];
	FC_ASSERT(rend);
	s_currentLuaTarget = rend;
	return 0;
}

@implementation FCRenderer_apple

@synthesize name = _name;
@synthesize models = _models;
@synthesize meshes = _meshes;
@synthesize gatherList = _gatherList;
@synthesize textureManager = _textureManager;

#pragma mark - FCSingleton protocol

-(id)initWithName:(NSString*)name
{
	self = [super init];
	if (self) {
		_name = name;
		_models = [[NSMutableArray alloc] init];
		_meshes = [[NSMutableArray alloc] init];
//		_gatherList = [[NSMutableArray alloc] init];
		
		if (!s_renderers) // one off init
		{
			s_renderers = [[NSMutableDictionary alloc] init];
//			[[FCLua instance].coreVM createGlobalTable:@"FCRenderer"];
			FCLua::Instance()->CoreVM()->CreateGlobalTable("FCRenderer");
//			[[FCLua instance].coreVM registerCFunction:lua_SetCurrentRenderer as:@"FCRenderer.SetCurrentRenderer"];
			FCLua::Instance()->CoreVM()->RegisterCFunction(lua_SetCurrentRenderer, "FCRenderer.SetCurrentRenderer");
		}
		
		[s_renderers setValue:self forKey:name];
	}
	return self;
}

-(void)dealloc
{
	[s_renderers removeObjectForKey:_name];
}

-(void)addToGatherList:(FCActorPtr)obj
{
//	FC_ASSERT([obj conformsToProtocol:@protocol(FCGameObjectRender)]);
//	[_gatherList addObject:obj];
	_gatherList.push_back(obj);
}

-(void)removeFromGatherList:(FCActorPtr)obj
{
//	FC_ASSERT([obj conformsToProtocol:@protocol(FCGameObjectRender)]);
//	[_gatherList removeObject:obj];
	for (FCActorVecIter i = _gatherList.begin(); i != _gatherList.end(); i++) {
		if (*i == obj) {
			_gatherList.erase(i);
			break;
		}
	}
}

-(void)render
{
	// go through gather list and aggregate the arrays
	
	[_models removeAllObjects];
	[_meshes removeAllObjects];
	
	// gather from objects on the gather list
	
	for (FCActorVecIter i = _gatherList.begin(); i != _gatherList.end(); i++)
	{
		[_models addObjectsFromArray:(*i)->RenderGather()];
	}

	for (FCModel_apple* model in _models) {
		[_meshes addObjectsFromArray:model.meshes];
	}
	
	// sorting here - by shader and alpha

	// render the models in sorted order
	
	GLuint lastShaderProgram = 99999;
	
	for( FCMesh_apple* mesh in _meshes )
	{
		FCMatrix4f mat = FCMatrix4f::Identity();
		FCMatrix4f trans = FCMatrix4f::Translate(mesh.parentModel.position.x, mesh.parentModel.position.y, 0.0f);
		FCMatrix4f rot = FCMatrix4f::Rotate(mesh.parentModel.rotation, FCVector3f(0.0f, 0.0f, -1.0f) );
		
		FCVector3f lightDirection( 0.707f, 0.707f, 0.707f );		
		FCVector3f invLight = lightDirection * rot;
		
		mat = rot * trans;
		
//			if (lastShaderProgram != mesh.shaderProgram.glHandle) 
//			{
				FCShaderUniform_apple* uniform = [mesh.shaderProgram getUniform:@"modelview"];		
				[mesh.shaderProgram setUniformValue:uniform to:&mat size:sizeof(mat)];
				
				uniform = [mesh.shaderProgram getUniform:@"light_direction"];
				if (uniform) {
					[mesh.shaderProgram setUniformValue:uniform to:&invLight size:sizeof(invLight)];
				}
				lastShaderProgram = mesh.shaderProgram.glHandle;
//			}
		
//		[_textureManager bindDebugTexture];

		[mesh render];
	}
	
//	for( FCModel* model in _models )
//	{
//		[model render];
//	}

//	[_models removeAllObjects];
}

@end

#endif // defined(FC_GRAPHICS)
