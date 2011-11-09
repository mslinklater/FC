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

#import "FCCategories.h"
#import "FCModel.h"
#import "FCMaths.h"
#import "FCKeys.h"
#import "FCXMLData.h"
#import "FCMesh.h"
#import "FCResource.h"
#import "FCShaderManager.h"
#import "FCShaderProgram.h"
#import "FCRenderer.h"
#import "FCVertexDescriptor.h"

static 	FC::Color4f	debugColor( 1.0f, 1.0f, 1.0f, 1.0f );
static int kNumCircleSegments = 16;
static FCVertexDescriptor* s_debugMeshVertexDescriptor;
static NSString* s_debugShaderName = @"debug_debug";

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
@synthesize meshes = _meshes;

#pragma mark -
#pragma mark Initialisers

+(void)initialize
{
	s_debugMeshVertexDescriptor = [[FCVertexDescriptor alloc] init];
	s_debugMeshVertexDescriptor.positionType = kFCVertexDescriptorPropertyTypeAttributeVec3;
	s_debugMeshVertexDescriptor.diffuseColorType = kFCVertexDescriptorPropertyTypeUniformVec4;
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
		
		self.meshes = [NSMutableArray array];
		
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
				[debugDict setValue:[fixture valueForKey:kFCKeyOffsetX] forKey:kFCKeyOffsetX];
				[debugDict setValue:[fixture valueForKey:kFCKeyOffsetY] forKey:kFCKeyOffsetY];
				[debugDict setValue:[fixture valueForKey:@"xSize"] forKey:kFCKeyXSize];
				[debugDict setValue:[fixture valueForKey:@"ySize"] forKey:kFCKeyYSize];
				
				[self addDebugRectangle:debugDict];
				
				[debugDict release];
			} 
			else if([type isEqualToString:@"circle"]) 
			{
				// circle
				NSMutableDictionary* debugDict = [[NSMutableDictionary alloc] init];
				[debugDict setValue:[fixture valueForKey:kFCKeyOffsetX] forKey:kFCKeyOffsetX];
				[debugDict setValue:[fixture valueForKey:kFCKeyOffsetY] forKey:kFCKeyOffsetY];
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
				
				[debugDict setValue:[NSString stringWithFormat:@"%d", numVerts] forKey:kFCKeyNumVertices];
				[debugDict setValue:[fixture valueForKey:@"verts"] forKey:@"verts"];
				[debugDict setValue:[fixture valueForKey:kFCKeyOffsetX] forKey:kFCKeyOffsetX];
				[debugDict setValue:[fixture valueForKey:kFCKeyOffsetY] forKey:kFCKeyOffsetY];
				
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
		NSArray* meshArray = [modelDict arrayForKey:kFCKeyMesh];;
		NSArray* binaryPayloadArray = [res.xmlData arrayForKeyPath:@"fcr.binarypayload.chunk"];
		(void)binaryPayloadArray;

		for( NSDictionary* mesh in meshArray )
		{
			NSString* shaderProgramName = [mesh valueForKey:kFCKeyShaderProgramName];
			(void)shaderProgramName;
			
			NSDictionary* buffers = [mesh valueForKey:kFCKeyBuffers];
			NSString* vertexBufferId = [buffers valueForKey:kFCKeyVertexBuffer];

			NSDictionary* chunkDictionary = nil; //= [binaryPayloadArray valueForKey:vertexBufferId];

			for( NSDictionary* dict in binaryPayloadArray )
			{
				if ([[dict valueForKey:kFCKeyId] isEqualToString:vertexBufferId]) {
					chunkDictionary = dict;
				}
			}
			
			
			NSString* vertexFormatString = [chunkDictionary valueForKey:kFCKeyVertexFormat];

			FCVertexDescriptor* resourceVertexDescriptor = [FCVertexDescriptor vertexDescriptorWithVertexFormatString:vertexFormatString 
																									   andUniformDict:mesh];
			
			FCShaderProgram* shaderProgram = [[FCRenderer instance].shaderManager program:shaderProgramName];
			FCVertexDescriptor* shaderVertexDescriptor = shaderProgram.requiredVertexDescriptor;
			
			if ([resourceVertexDescriptor canSatisfy:shaderVertexDescriptor]) {
				// bind etc
			}
			else
			{
				FC_ERROR(@"Shader binding error for model");
			}
			
			NSLog(@"%@", resourceVertexDescriptor);
		}
		
		// get vertex description provided by the resource
		
		// check the shaders can get all they need from the resource
		
		// build meshes
		
#if 0
		self.meshes = [NSMutableArray array];

		NSArray* meshesArray;
		
		if ([[modelDict valueForKey:@"mesh"] isKindOfClass:[NSArray class]]) 
		{
			meshesArray = [modelDict valueForKey:@"mesh"];
		}
		else
		{
			meshesArray = [NSArray arrayWithObject:[modelDict valueForKey:@"mesh"]];
		}
		
		for (NSDictionary* meshDict in meshesArray)
		{
			NSArray* chunks = [res.xmlData arrayForKeyPath:@"fcr.binarypayload.chunk"];
			
			NSString* vertexBufferChunkName = [meshDict valueForKey:kFCKeyVertexBuffer];
			NSDictionary* vertexBufferChunk = nil;
			
			for(NSDictionary* chunk in chunks)
			{
				NSString* chunkId = [chunk valueForKey:kFCKeyId];
				
				if( [chunkId isEqualToString:vertexBufferChunkName] ) 
				{
					vertexBufferChunk = [chunk retain];
				}
			}

			FC_ASSERT(vertexBufferChunk);
			
			NSInteger numTriangles = [[vertexBufferChunk valueForKey:kFCKeyNumTriangles] intValue];

			FCMesh* mesh = [[FCMesh alloc] initWithNumVertices:numTriangles * 3 numTriangles:numTriangles];

			// copy vertex buffer over
			
//			NSInteger vertexSrcOffset = [[vertexChunk valueForKey:@"offset"] intValue];
//			NSInteger vertexSrcSize = [[vertexChunk valueForKey:@"size"] intValue];
//			
//			FC::Vector3f* destVertices = [mesh vertexNum:0];
//			NSRange range;
//			range.location = vertexSrcOffset;
//			range.length = vertexSrcSize;
//			[res.binaryPayload getBytes:destVertices range:range];
//			
//			// create color buffer
//			
//			FC::Color4f* pColor;
//			
//			for (int i = 0 ; i < numVerts; i++) 
//			{
//				pColor = [mesh colorNum:i];
//				pColor->r = debugColor.r;
//				pColor->g = debugColor.g;
//				pColor->b = debugColor.b;
//				pColor->a = debugColor.a;
//			}
//
//			// copy index buffer over - need to set the format so both debug and proper indexes work.
//
//			[mesh fixup];
//			[self.meshes addObject:mesh];
//			
			[mesh release];
			[vertexBufferChunk release];
		}
#endif
	}
	return self;
}

-(void)render
{
	FC::Matrix4f mat = FC::Matrix4f::Identity();
	FC::Matrix4f trans = FC::Matrix4f::Translate(self.position.x, self.position.y, 0.0f);
	FC::Matrix4f rot = FC::Matrix4f::Rotate(self.rotation, FC::Vector3f(0.0f, 0.0f, -1.0f) );
	
	mat = rot * trans;
		
	for (FCMesh* mesh in self.meshes) 
	{
		FCShaderUniform* uniform = [mesh.shaderProgram getUniform:@"modelview"];		
		[mesh.shaderProgram setUniformValue:uniform to:&mat size:sizeof(mat)];

		[mesh render];
	}
}

-(void)addDebugCircle:(NSDictionary*)def
{
	FCMesh* mesh = [FCMesh fcMeshWithVertexDescriptor:s_debugMeshVertexDescriptor shaderName:s_debugShaderName];
	[self.meshes addObject:mesh];

	mesh.numVertices = kNumCircleSegments + 1;
	mesh.numTriangles = kNumCircleSegments;
	
	float radius = [[def valueForKey:kFCKeyRadius] floatValue];
	
	FC::Vector3f* pVert;
	FC::Vector3f center;
	center.x = [[def valueForKey:kFCKeyOffsetX] floatValue];
	center.y = [[def valueForKey:kFCKeyOffsetY] floatValue];
	center.z = 0.0f;

	pVert = (FC::Vector3f*)((unsigned long)mesh.pVertexBuffer + mesh.vertexDescriptor.positionOffset);
	pVert->x = center.x;
	pVert->y = center.y;
	pVert->z = center.z;

	for( int i = 0 ; i < kNumCircleSegments ; i++ )
	{		
		float angle1 = ( 3.142f * 2.0f / kNumCircleSegments ) * i;
		
		pVert = (FC::Vector3f*)((unsigned int)pVert + mesh.vertexDescriptor.stride);
		
		pVert->x = center.x + sinf( angle1 ) * radius;
		pVert->y = center.y + cosf( angle1 ) * radius;
		pVert->z = center.z;		
	}

	mesh.colorUniform = debugColor;
	
	FC::Vector3us* pIndex;
	
	for (int i = 0 ; i < kNumCircleSegments - 1; i++) 
	{
		pIndex = [mesh pIndexBufferAtIndex:i];
		pIndex->x = 0;
		pIndex->y = i+1;
		pIndex->z = i+2;
	}

	pIndex = [mesh pIndexBufferAtIndex:kNumCircleSegments - 1];
	pIndex->x = 0;
	pIndex->y = kNumCircleSegments;
	pIndex->z = 1;

}

-(void)addDebugRectangle:(NSDictionary*)def
{
	FCMesh* mesh = [FCMesh fcMeshWithVertexDescriptor:s_debugMeshVertexDescriptor shaderName:s_debugShaderName];
	[self.meshes addObject:mesh];

	mesh.numVertices = 4;
	mesh.numTriangles = 2;
	
	FC::Vector2f size( [[def valueForKey:kFCKeyXSize] floatValue] * 0.5f, [[def valueForKey:kFCKeyYSize] floatValue] * 0.5f);

	FC::Vector3f center;
	center.x = [[def valueForKey:kFCKeyOffsetX] floatValue];
	center.y = [[def valueForKey:kFCKeyOffsetY] floatValue];
	center.z = 0.0f;

	FC::Vector3f* pVert;
	
	pVert = (FC::Vector3f*)((unsigned long)mesh.pVertexBuffer + mesh.vertexDescriptor.positionOffset);
	pVert->x = center.x + size.x * -1.0f;
	pVert->y = center.y + size.y * -1.0f;
	pVert->z = center.z;
	
	pVert = (FC::Vector3f*)((unsigned int)pVert + mesh.vertexDescriptor.stride);
	pVert->x = center.x + size.x * 1.0f;
	pVert->y = center.y + size.y * -1.0f;
	pVert->z = center.z;
	
	pVert = (FC::Vector3f*)((unsigned int)pVert + mesh.vertexDescriptor.stride);
	pVert->x = center.x + size.x * 1.0f;
	pVert->y = center.y + size.y * 1.0f;
	pVert->z = center.z;
	
	pVert = (FC::Vector3f*)((unsigned int)pVert + mesh.vertexDescriptor.stride);
	pVert->x = center.x + size.x * -1.0f;
	pVert->y = center.y + size.y * 1.0f;
	pVert->z = center.z;
	
	mesh.colorUniform = debugColor;

	FC::Vector3us* pIndex;
	
	pIndex = [mesh pIndexBufferAtIndex:0];
	pIndex->x = 0;
	pIndex->y = 1;
	pIndex->z = 2;
	pIndex = [mesh pIndexBufferAtIndex:1];
	pIndex->x = 0;
	pIndex->y = 2;
	pIndex->z = 3;
}

-(void)addDebugPolygon:(NSDictionary*)def
{
	FCMesh* mesh = [FCMesh fcMeshWithVertexDescriptor:s_debugMeshVertexDescriptor shaderName:s_debugShaderName];
	[self.meshes addObject:mesh];
	
	mesh.numVertices = [[def valueForKey:kFCKeyNumVertices] intValue];
	mesh.numTriangles = mesh.numVertices - 2;
	
	FC::Vector3f* pVert;

	NSArray* vertsArray = [[def valueForKeyPath:@"verts"] componentsSeparatedByString:@" "];

	pVert = (FC::Vector3f*)((unsigned long)mesh.pVertexBuffer + mesh.vertexDescriptor.positionOffset);
	
	float xOffset = [[def valueForKey:kFCKeyOffsetX] floatValue];
	float yOffset = [[def valueForKey:kFCKeyOffsetY] floatValue];
	
	pVert->x = [[vertsArray objectAtIndex:0] floatValue] + xOffset;
	pVert->y = [[vertsArray objectAtIndex:1] floatValue] + yOffset;
	pVert->z = 0.0f;

	for (int i = 1 ; i < mesh.numVertices ; i++) 
	{
		pVert = (FC::Vector3f*)((unsigned int)pVert + mesh.vertexDescriptor.stride);
		pVert->x = [[vertsArray objectAtIndex:i*2] floatValue] + xOffset;
		pVert->y = [[vertsArray objectAtIndex:(i*2)+1] floatValue] + yOffset;
		pVert->z = 0.0f;
	}	

	mesh.colorUniform = debugColor;

	FC::Vector3us* pIndex;
	
	for (int i = 0; i < mesh.numTriangles; i++)
	{
		pIndex = [mesh pIndexBufferAtIndex:i];
		pIndex->x = 0;
		pIndex->y = i+1;
		pIndex->z = i+2;
	}
}

-(void)dealloc
{
	self.meshes = nil;
	[super dealloc];
}
@end

#endif // TARGET_OS_IPHONE
