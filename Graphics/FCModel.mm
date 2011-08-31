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

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "FCModel.h"
#import "FCMaths.h"
#import "FCKeys.h"
#import "FCXMLData.h"
#import "FCMesh.h"
#import "FCResource.h"
#import "FCShaderManager.h"
#import "FCRenderer.h"

static 	FC::Color4f	debugColor( 1.0f, 1.0f, 1.0f, 1.0f );
static int kNumCircleSegments = 16;

#pragma mark - Private interface

@interface FCModel(hidden)
-(void)addDebugCircle:(NSDictionary*)def;
-(void)addDebugRectangle:(NSDictionary*)def;
-(void)addDebugPolygon:(NSDictionary*)def;
@end

#pragma mark - Public interface

@implementation FCModel

@synthesize position = _position;
@synthesize rotation = _rotation;

#pragma mark -
#pragma mark Initialisers

+(void)initialize
{
}

+(void)setDebugColor:(FC::Color4f)col
{
	debugColor = col;
}

-(id)initWithPhysicsBody:(NSDictionary *)bodyDict
{
	self = [super init];
	if (self) {
		// go through meshes and build for fixtures
		
		mMeshes = [[NSMutableArray alloc] init];

		NSArray* fixtures;
		
		if ([[bodyDict valueForKey:@"fixture"] isKindOfClass:[NSDictionary class]]) {
			fixtures = [NSArray arrayWithObject:[bodyDict valueForKey:@"fixture"]];
		} else {
			fixtures = [bodyDict valueForKey:@"fixture"];
		}
		
		for (NSDictionary* fixture in fixtures) 
		{
			NSString* type = [fixture valueForKey:@"type"];
			
			if ([type isEqualToString:@"rectangle"]) 
			{
				// rectangle
				NSMutableDictionary* debugDict = [[NSMutableDictionary alloc] init];
				[debugDict setValue:[fixture valueForKey:@"xOffset"] forKey:@"xOffset"];
				[debugDict setValue:[fixture valueForKey:@"yOffset"] forKey:@"yOffset"];
				[debugDict setValue:[fixture valueForKey:@"xSize"] forKey:kFCKeyXSize];
				[debugDict setValue:[fixture valueForKey:@"ySize"] forKey:kFCKeyYSize];
				
				[self addDebugRectangle:debugDict];
				
				[debugDict release];
			} 
			else if([type isEqualToString:@"circle"]) 
			{
				// circle
				NSMutableDictionary* debugDict = [[NSMutableDictionary alloc] init];
				[debugDict setValue:[fixture valueForKey:@"xOffset"] forKey:@"xOffset"];
				[debugDict setValue:[fixture valueForKey:@"yOffset"] forKey:@"yOffset"];
				[debugDict setValue:[fixture valueForKey:@"radius"] forKey:kFCKeyRadius];
				
				[self addDebugCircle:debugDict];
				
				[debugDict release];
			} 
			else if([type isEqualToString:@"polygon"]) 
			{
				// polygon
				NSMutableDictionary* debugDict = [[NSMutableDictionary alloc] init];

				NSArray* floatArray = [[fixture valueForKey:@"verts"] componentsSeparatedByString:@" "];

				int numVerts = [floatArray count] / 2;
				
				[debugDict setValue:[NSString stringWithFormat:@"%d", numVerts] forKey:kFCKeyNumVerts];
				[debugDict setValue:[fixture valueForKey:@"verts"] forKey:@"verts"];
				[debugDict setValue:[fixture valueForKey:@"xOffset"] forKey:@"xOffset"];
				[debugDict setValue:[fixture valueForKey:@"yOffset"] forKey:@"yOffset"];
				
				[self addDebugPolygon:debugDict];
				
				[debugDict release];
			}
		}
	}
	return self;
}

-(id)initWithModel:(NSDictionary*)modelDict resource:(FCResource*)res
{
	self = [super init];
	if (self) 
	{
		mMeshes = [[NSMutableArray alloc] init];

		NSArray* meshes;
		
		if ([[modelDict valueForKey:@"mesh"] isKindOfClass:[NSArray class]]) {
			meshes = [modelDict valueForKey:@"mesh"];
		}
		else
		{
			meshes = [NSArray arrayWithObject:[modelDict valueForKey:@"mesh"]];
		}
		
		for (NSDictionary* meshDict in meshes)
		{
			NSArray* chunks = [res.xmlData arrayForKeyPath:@"fcr.binarypayload.chunk"];
			
			NSString* vertexChunkName = [meshDict valueForKey:@"fcvertexarray"];
			NSDictionary* vertexChunk = nil;
			
//			NSString* normalChunkName = [meshDict valueForKey:kFCKeyNormalArray];
//			NSDictionary* normalChunk = nil;

			NSString* indexChunkName = [meshDict valueForKey:@"fcindexarray"];
			NSDictionary* indexChunk = nil;
			
			for(NSDictionary* chunk in chunks)
			{
				NSString* chunkId = [chunk valueForKey:kFCKeyId];
				
				if ( [chunkId isEqualToString:vertexChunkName]) {
					vertexChunk = chunk;
				}
//				if ([chunkId isEqualToString:normalChunkName]) {
//					normalChunk = chunk;
//				}
				if ([chunkId isEqualToString:indexChunkName]) {
					indexChunk = chunk;
				}
			}

			NSInteger numVerts = [[vertexChunk valueForKey:kFCKeyCount] intValue];
			NSInteger numTriangles = [[indexChunk valueForKey:@"numtris"] intValue];
			
			FCMesh* mesh = [[FCMesh alloc] initWithNumVertices:numVerts numTriangles:numTriangles];

			// copy vertex buffer over
			
			NSInteger vertexSrcOffset = [[vertexChunk valueForKey:@"offset"] intValue];
			NSInteger vertexSrcSize = [[vertexChunk valueForKey:@"size"] intValue];
			
			FC::Vector3f* destVertices = [mesh vertexNum:0];
			NSRange range;
			range.location = vertexSrcOffset;
			range.length = vertexSrcSize;
			[res.binaryPayload getBytes:destVertices range:range];
			
			// create color buffer
			
			FC::Color4f* pColor;
			
			for (int i = 0 ; i < numVerts; i++) 
			{
				pColor = [mesh colorNum:i];
				pColor->r = debugColor.r;
				pColor->g = debugColor.g;
				pColor->b = debugColor.b;
				pColor->a = debugColor.a;
			}

			// copy index buffer over - need to set the format so both debug and proper indexes work.

			[mesh fixup];
			[mMeshes addObject:mesh];
			
			[mesh release];
		}
	}
	return self;
}

-(void)render
{
	FCShaderProgram* program = [[FCRenderer instance].shaderManager program:@"simple_simple"];
	FCShaderUniform* uniform = [program getUniform:@"Modelview"];
	
	FC::Matrix4f mat = FC::Matrix4f::Identity();
	FC::Matrix4f trans = FC::Matrix4f::Translate(self.position.x, self.position.y, 0.0f);
	FC::Matrix4f rot = FC::Matrix4f::Rotate(self.rotation, FC::Vector3f(0.0f, 0.0f, -1.0f) );
	
	mat = rot * trans;
	
	[program setUniformValue:uniform to:&mat size:sizeof(mat)];
	
	for (FCMesh* mesh in mMeshes) 
	{
		[mesh render];
	}
}

-(void)addDebugCircle:(NSDictionary*)def
{
	int numVerts = kNumCircleSegments + 1;

	FCMesh* mesh = [[FCMesh alloc] initWithNumVertices:numVerts numTriangles:kNumCircleSegments];

	float radius = [[def valueForKey:@"radius"] floatValue];
	
	FC::Vector3f* pVert;
	FC::Vector3f center;
	center.x = [[def valueForKey:@"xOffset"] floatValue];
	center.y = [[def valueForKey:@"yOffset"] floatValue];
	center.z = 0.0f;

	pVert = [mesh vertexNum:0];
	pVert->x = center.x;
	pVert->y = center.y;
	pVert->z = center.z;

	for( int i = 0 ; i < kNumCircleSegments ; i++ )
	{		
		float angle1 = ( 3.142f * 2.0f / kNumCircleSegments ) * i;
		
		pVert = [mesh vertexNum:i+1];
		pVert->x = center.x + sinf( angle1 ) * radius;
		pVert->y = center.y + cosf( angle1 ) * radius;
		pVert->z = center.z;		
	}
	
	FC::Color4f* pColor;
	
	for (int i = 0 ; i < numVerts; i++) 
	{
		pColor = [mesh colorNum:i];
		pColor->r = debugColor.r;
		pColor->g = debugColor.g;
		pColor->b = debugColor.b;
		pColor->a = debugColor.a;
	}
	
	FC::Vector3s* pIndex;
	
	for (int i = 0 ; i < kNumCircleSegments - 1; i++) 
	{
		pIndex = [mesh indexNum:i];
		pIndex->x = 0;
		pIndex->y = i+1;
		pIndex->z = i+2;
	}

	pIndex = [mesh indexNum:kNumCircleSegments - 1];
	pIndex->x = 0;
	pIndex->y = kNumCircleSegments;
	pIndex->z = 1;

	[mesh fixup];
	[mMeshes addObject:mesh];
	[mesh release];
}

-(void)addDebugRectangle:(NSDictionary*)def
{
	int numVerts = 4;
	int numTriangles = 2;
	FC::Vector2f size( [[def valueForKey:kFCKeyXSize] floatValue] * 0.5f, [[def valueForKey:kFCKeyYSize] floatValue] * 0.5f);

	FCMesh* mesh = [[FCMesh alloc] initWithNumVertices:numVerts numTriangles:numTriangles];
	
	FC::Vector3f center;
	center.x = [[def valueForKey:@"xOffset"] floatValue];
	center.y = [[def valueForKey:@"yOffset"] floatValue];
	center.z = 0.0f;

	FC::Vector3f* pVert = [mesh vertexNum:0];
	pVert->x = center.x + size.x * -1.0f;
	pVert->y = center.y + size.y * -1.0f;
	pVert->z = center.z;
	
	pVert = [mesh vertexNum:1];
	pVert->x = center.x + size.x * 1.0f;
	pVert->y = center.y + size.y * -1.0f;
	pVert->z = center.z;
	
	pVert = [mesh vertexNum:2];
	pVert->x = center.x + size.x * 1.0f;
	pVert->y = center.y + size.y * 1.0f;
	pVert->z = center.z;
	
	pVert = [mesh vertexNum:3];
	pVert->x = center.x + size.x * -1.0f;
	pVert->y = center.y + size.y * 1.0f;
	pVert->z = center.z;
	
	FC::Color4f* pColor;
	
	for (int i = 0; i < numVerts; i++) 
	{
		pColor = [mesh colorNum:i];
		pColor->r = debugColor.r;
		pColor->g = debugColor.g;
		pColor->b = debugColor.b;
		pColor->a = debugColor.a;
	}	

	FC::Vector3s* pIndex;
	
	pIndex = [mesh indexNum:0];
	pIndex->x = 0;
	pIndex->y = 1;
	pIndex->z = 2;
	pIndex = [mesh indexNum:1];
	pIndex->x = 0;
	pIndex->y = 2;
	pIndex->z = 3;
	
	[mesh fixup];

	[mMeshes addObject:mesh];
	[mesh release];
}

-(void)addDebugPolygon:(NSDictionary*)def
{
	int numVerts = [[def valueForKey:kFCKeyNumVerts] intValue];
	int numTriangles =  numVerts - 2;
	
	FCMesh* mesh = [[FCMesh alloc] initWithNumVertices:numVerts numTriangles:numTriangles];
	
	FC::Vector3f* pVert;

	NSArray* vertsArray = [[def valueForKeyPath:@"verts"] componentsSeparatedByString:@" "];

	pVert = [mesh vertexNum:0];
	
	float xOffset = [[def valueForKey:@"xOffset"] floatValue];
	float yOffset = [[def valueForKey:@"yOffset"] floatValue];
	
	pVert->x = [[vertsArray objectAtIndex:0] floatValue] + xOffset;
	pVert->y = [[vertsArray objectAtIndex:1] floatValue] + yOffset;
	pVert->z = 0.0f;

	for (int i = 1 ; i < numVerts ; i++) 
	{
		pVert = [mesh vertexNum:i];
		pVert->x = [[vertsArray objectAtIndex:i*2] floatValue] + xOffset;
		pVert->y = [[vertsArray objectAtIndex:(i*2)+1] floatValue] + yOffset;
		pVert->z = 0.0f;
	}	

	FC::Color4f* pColor;
	for (int i = 0; i < numVerts; i++)
	{
		pColor = [mesh colorNum:i];
		pColor->r = debugColor.r;
		pColor->g = debugColor.g;
		pColor->b = debugColor.b;
		pColor->a = debugColor.a;
	}	
	
	FC::Vector3s* pIndex;
	
	for (int i = 0; i < numTriangles; i++) 
	{
		pIndex = [mesh indexNum:i];
		pIndex->x = 0;
		pIndex->y = i+1;
		pIndex->z = i+2;
	}
	
	[mesh fixup];

	[mMeshes addObject:mesh];
	[mesh release];
}

-(void)dealloc
{
	[mMeshes release], mMeshes = nil;
	[super dealloc];
}
@end

#endif // TARGET_OS_IPHONE
