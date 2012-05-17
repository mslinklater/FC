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

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "FCModel.h"
#import "FCMaths.h"
#import "FCKeys.h"
#import "FCMesh.h"
#import "FCResource.h"
#import "FCShaderManager.h"
#import "FCShaderProgram.h"
#import "FCRenderer.h"

static 	FCColor4f	s_whiteColor( 1.0f, 1.0f, 1.0f, 1.0f );
static int kNumCircleSegments = 36;

#pragma mark - Private interface

@interface FCModel(hidden)
-(void)addDebugCircle:(NSDictionary*)def color:(UIColor*)debugColor;
-(void)addDebugRectangle:(NSDictionary*)def color:(UIColor*)debugColor;
-(void)addDebugPolygon:(NSDictionary*)def color:(UIColor*)debugColor;
@end

#pragma mark - Public interface

@implementation FCModel

@synthesize position = _position;
@synthesize rotation = _rotation;
@synthesize meshes = _meshes;

#pragma mark -
#pragma mark Initialisers

-(id)initWithPhysicsBody:(FCXMLNode)bodyXML color:(UIColor*)color	//actorXOffset:(float)actorX actorYOffset:(float)actorY
{
	self = [super init];
	if (self) {
		// go through meshes and build for fixtures
		
		self.meshes = [NSMutableArray array];
		
		
		FCXMLNodeVec fixtures = FCXML::VectorForChildNodesOfType(bodyXML, "fixture");
		
		for (FCXMLNodeVecIter fixture = fixtures.begin(); fixture != fixtures.end(); fixture++)
		{
			NSString* type = [NSString stringWithUTF8String:FCXML::StringValueForNodeAttribute(*fixture, "type").c_str()];
			
			float fixtureX = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetX);
			float fixtureY = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetY);
			float fixtureZ = FCXML::FloatValueForNodeAttribute(*fixture, kFCKeyOffsetZ);
			
			if ([type isEqualToString:@"box"]) 
			{
				// box
				NSMutableDictionary* debugDict = [[NSMutableDictionary alloc] init];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureX] forKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureY] forKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureZ] forKey:[NSString stringWithUTF8String:kFCKeyOffsetZ.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:FCXML::FloatValueForNodeAttribute(*fixture, "xSize")] forKey:[NSString stringWithUTF8String:kFCKeyXSize.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:FCXML::FloatValueForNodeAttribute(*fixture, "ySize")] forKey:[NSString stringWithUTF8String:kFCKeyYSize.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:FCXML::FloatValueForNodeAttribute(*fixture, "zSize")] forKey:[NSString stringWithUTF8String:kFCKeyZSize.c_str()]];
				
				[self addDebugRectangle:debugDict color:color];
			} 
			else if([type isEqualToString:@"circle"]) 
			{
				// circle
				NSMutableDictionary* debugDict = [[NSMutableDictionary alloc] init];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureX] forKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureY] forKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureZ] forKey:[NSString stringWithUTF8String:kFCKeyOffsetZ.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:FCXML::FloatValueForNodeAttribute(*fixture, "radius")] forKey:[NSString stringWithUTF8String:kFCKeyRadius.c_str()]];
				
				[self addDebugCircle:debugDict color:color];				
			} 
			else if([type isEqualToString:@"hull"]) 
			{
				// polygon
				NSMutableDictionary* debugDict = [[NSMutableDictionary alloc] init];

				NSString* strippedVerts = [NSString stringWithUTF8String:FCXML::StringValueForNodeAttribute(*fixture, "verts").c_str()];
				strippedVerts = [strippedVerts stringByReplacingOccurrencesOfString:@"," withString:@" "];
				strippedVerts = [strippedVerts stringByReplacingOccurrencesOfString:@"(" withString:@""];
				strippedVerts = [strippedVerts stringByReplacingOccurrencesOfString:@")" withString:@""];
				
				NSArray* floatArray = [strippedVerts componentsSeparatedByString:@" "];

				int numVerts = [floatArray count] / 3;
				
				[debugDict setValue:[NSString stringWithFormat:@"%d", numVerts] forKey:[NSString stringWithUTF8String:kFCKeyNumVertices.c_str()]];
				[debugDict setValue:strippedVerts forKey:@"verts"];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureX] forKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureY] forKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureZ] forKey:[NSString stringWithUTF8String:kFCKeyOffsetZ.c_str()]];
				
				[self addDebugPolygon:debugDict color:color];
			}
		}
	}
	return self;
}

-(id)initWithModel:(FCXMLNode)modelXML resource:(FCResourcePtr)res
{
	self = [super init];
	if (self) 
	{
		FCXMLNodeVec meshArray = FCXML::VectorForChildNodesOfType(modelXML, kFCKeyMesh);
		
		FCXMLNodeVec binaryPayloadArray = res->XML()->VectorForKeyPath("fcr.binarypayload.chunk");
		
		self.meshes = [NSMutableArray array];
		
		for (FCXMLNodeVecIter mesh = meshArray.begin(); mesh != meshArray.end(); mesh++)
		{
			std::string shaderName = FCXML::StringValueForNodeAttribute(*mesh, kFCKeyShader);
			
			std::string indexBufferId = FCXML::StringValueForNodeAttribute(*mesh, kFCKeyIndexBuffer);
			std::string vertexBufferId = FCXML::StringValueForNodeAttribute(*mesh, kFCKeyVertexBuffer);

			FCXMLNode indexBufferXML = 0;
			FCXMLNode vertexBufferXML = 0;
			
			for (FCXMLNodeVecIter chunk = binaryPayloadArray.begin(); chunk != binaryPayloadArray.end(); chunk++) 
			{
				if (FCXML::StringValueForNodeAttribute(*chunk, kFCKeyId) == indexBufferId) {
					indexBufferXML = *chunk;
				}
				if (FCXML::StringValueForNodeAttribute(*chunk, kFCKeyId) == vertexBufferId) {
					vertexBufferXML = *chunk;
				}
			}
			
			FC_ASSERT( indexBufferXML && vertexBufferXML );
			
			// all looks good so far - lets build the mesh

			GLenum primitiveType = GL_TRIANGLES;
			
			if (shaderName == kFCKeyShaderWireframe ) {
				primitiveType = GL_LINES;
			}
			
			FCMesh* meshObject = [[FCMesh alloc] initWithVertexDescriptor:nil 
															   shaderName:[NSString stringWithUTF8String:shaderName.c_str()]
															primitiveType:primitiveType];
			
			
			meshObject.numVertices = FCXML::IntValueForNodeAttribute(*mesh, kFCKeyNumVertices);
			meshObject.numTriangles = FCXML::IntValueForNodeAttribute(*mesh, kFCKeyNumTriangles);
			meshObject.numEdges = FCXML::IntValueForNodeAttribute(*mesh, kFCKeyNumEdges);
			
			// specular color
			
			if ((FCXML::StringValueForNodeAttribute(*mesh, "specular_r").size()) && 
				(FCXML::StringValueForNodeAttribute(*mesh, "specular_g").size()) && 
				(FCXML::StringValueForNodeAttribute(*mesh, "specular_b").size()))
			{
				FCColor4f specular;
				specular.r = FCXML::FloatValueForNodeAttribute(*mesh, "specular_r");		//[[mesh valueForKey:@"specular_r"] floatValue];
				specular.g = FCXML::FloatValueForNodeAttribute(*mesh, "specular_g");	//[[mesh valueForKey:@"specular_g"] floatValue];
				specular.b = FCXML::FloatValueForNodeAttribute(*mesh, "specular_b");	//[[mesh valueForKey:@"specular_b"] floatValue];
				specular.a = 1.0f;
				meshObject.specularColor = specular;
			}
			
			// copy across vertex and index buffers

			NSUInteger indexBufferOffset = (NSUInteger)FCXML::IntValueForNodeAttribute(indexBufferXML, "offset");
			NSUInteger indexBufferSize = (NSUInteger)FCXML::IntValueForNodeAttribute(indexBufferXML, "size");
//			[res.binaryPayload getBytes:meshObject.pIndexBuffer range:NSMakeRange(indexBufferOffset, indexBufferSize)];
			
			memcpy(meshObject.pIndexBuffer, res->BinaryPayload() + indexBufferOffset, indexBufferSize);
			
			NSUInteger vertexBufferOffset = (NSUInteger)FCXML::IntValueForNodeAttribute(vertexBufferXML, "offset");
			NSUInteger vertexBufferSize = (NSUInteger)FCXML::IntValueForNodeAttribute(vertexBufferXML, "size");
//			[res.binaryPayload getBytes:meshObject.pVertexBuffer range:NSMakeRange(vertexBufferOffset, vertexBufferSize)];
			memcpy(meshObject.pVertexBuffer, res->BinaryPayload() + vertexBufferOffset, vertexBufferSize);
					
			NSString* diffuseString = [NSString stringWithUTF8String:FCXML::StringValueForNodeAttribute(*mesh, kFCKeyDiffuseColor).c_str()];
			if (diffuseString && [diffuseString length]) {
				NSArray* components = [diffuseString componentsSeparatedByString:@","];
				meshObject.diffuseColor = FCColor4f([[components objectAtIndex:0] floatValue], 
													  [[components objectAtIndex:1] floatValue], 
													  [[components objectAtIndex:2] floatValue], 1.0f );
			}

			meshObject.parentModel = self;
			[self.meshes addObject:meshObject];
		}
	}
	return self;
}

-(void)setDebugMeshColor:(FCColor4f)color
{
	for( FCMesh* mesh in _meshes )
	{
		mesh.diffuseColor = color;
	}
}

-(void)addDebugCircle:(NSDictionary*)def color:(UIColor*)debugColor
{
	FCMesh* mesh = [[FCMesh alloc] initWithVertexDescriptor:nil 
										   shaderName:[NSString stringWithUTF8String:kFCKeyShaderDebug.c_str()] primitiveType:GL_TRIANGLES];
	[self.meshes addObject:mesh];
	mesh.parentModel = self;

	mesh.numVertices = kNumCircleSegments + 1;
	mesh.numTriangles = kNumCircleSegments;
	
	float radius = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyRadius.c_str()]] floatValue];
	
	FCVector3f* pVert;
	FCVector3f center;
	center.x = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]] floatValue];
	center.y = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]] floatValue];
	center.z = 0.0f;

	pVert = (FCVector3f*)((unsigned long)mesh.pVertexBuffer);
	pVert->x = center.x;
	pVert->y = center.y;
	pVert->z = center.z;

	for( int i = 0 ; i < kNumCircleSegments ; i++ )
	{		
		float angle1 = ( 3.142f * 2.0f / kNumCircleSegments ) * i;
		
		pVert = (FCVector3f*)((unsigned int)pVert + 12);
		
		pVert->x = center.x + sinf( angle1 ) * radius;
		pVert->y = center.y + cosf( angle1 ) * radius;
		pVert->z = center.z;		
	}

	if (debugColor) {
		float red, green, blue, alpha;
		[debugColor getRed:&red green:&green blue:&blue alpha:&alpha];
		mesh.diffuseColor = FCColor4f( red, green, blue, alpha );
	}
	else
		mesh.diffuseColor = s_whiteColor;
	
	unsigned short* pIndex;
	
	for (int i = 0 ; i < kNumCircleSegments - 1; i++) 
	{
		pIndex = [mesh pIndexBufferAtIndex:i*3];
		*pIndex = 0;
		*(pIndex+1) = i+1;
		*(pIndex+2) = i+2;
	}

	pIndex = [mesh pIndexBufferAtIndex:(kNumCircleSegments - 1) * 3];
	*pIndex = 0;
	*(pIndex+1) = kNumCircleSegments;
	*(pIndex+2) = 1;
}

-(void)addDebugRectangle:(NSDictionary*)def color:(UIColor *)debugColor
{
	FCMesh* mesh = [[FCMesh alloc] initWithVertexDescriptor:nil 
												 shaderName:[NSString stringWithUTF8String:kFCKeyShaderDebug.c_str()] primitiveType:GL_TRIANGLES];
	[self.meshes addObject:mesh];
	mesh.parentModel = self;

	mesh.numVertices = 4;
	mesh.numTriangles = 2;
	
	FCVector2f size( [[def valueForKey:[NSString stringWithUTF8String:kFCKeyXSize.c_str()]] floatValue] * 0.5f, 
					  [[def valueForKey:[NSString stringWithUTF8String:kFCKeyYSize.c_str()]] floatValue] * 0.5f);

	FCVector3f center;
	center.x = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]] floatValue];
	center.y = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]] floatValue];
	center.z = 0.0f;

	FCVector3f* pVert;
	
	pVert = (FCVector3f*)((unsigned long)mesh.pVertexBuffer);
	pVert->x = center.x + size.x * -1.0f;
	pVert->y = center.y + size.y * -1.0f;
	pVert->z = center.z;
	
	pVert = (FCVector3f*)((unsigned int)pVert + 12);
	pVert->x = center.x + size.x * 1.0f;
	pVert->y = center.y + size.y * -1.0f;
	pVert->z = center.z;
	
	pVert = (FCVector3f*)((unsigned int)pVert + 12);
	pVert->x = center.x + size.x * 1.0f;
	pVert->y = center.y + size.y * 1.0f;
	pVert->z = center.z;
	
	pVert = (FCVector3f*)((unsigned int)pVert + 12);
	pVert->x = center.x + size.x * -1.0f;
	pVert->y = center.y + size.y * 1.0f;
	pVert->z = center.z;
	
	if (debugColor) {
		float red, green, blue, alpha;
		[debugColor getRed:&red green:&green blue:&blue alpha:&alpha];
		mesh.diffuseColor = FCColor4f( red, green, blue, alpha );
	}
	else
		mesh.diffuseColor = s_whiteColor;

	unsigned short* pIndex;
	
	pIndex = [mesh pIndexBufferAtIndex:0];
	*pIndex = 0;
	*(pIndex+1) = 1;
	*(pIndex+2) = 2;
	pIndex = [mesh pIndexBufferAtIndex:3];
	*pIndex = 0;
	*(pIndex+1) = 2;
	*(pIndex+2) = 3;
}

-(void)addDebugPolygon:(NSDictionary*)def color:(UIColor *)debugColor
{
	FCMesh* mesh = [[FCMesh alloc] initWithVertexDescriptor:nil 
												 shaderName:[NSString stringWithUTF8String:kFCKeyShaderDebug.c_str()] primitiveType:GL_TRIANGLES];
	[self.meshes addObject:mesh];
	mesh.parentModel = self;

	mesh.numVertices = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyNumVertices.c_str()]] intValue];
	mesh.numTriangles = mesh.numVertices - 2;
	
	FCVector3f* pVert;

	NSArray* vertsArray = [[def valueForKeyPath:@"verts"] componentsSeparatedByString:@" "];

	pVert = (FCVector3f*)((unsigned long)mesh.pVertexBuffer);
	
	float xOffset = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]] floatValue];
	float yOffset = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]] floatValue];
	float zOffset = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetZ.c_str()]] floatValue];
	
	pVert->x = [[vertsArray objectAtIndex:0] floatValue] + xOffset;
	pVert->y = [[vertsArray objectAtIndex:1] floatValue] + yOffset;
	pVert->z = [[vertsArray objectAtIndex:2] floatValue] + zOffset;

	for (int i = 1 ; i < mesh.numVertices ; i++) 
	{
		pVert = (FCVector3f*)((unsigned int)pVert + 12);
		pVert->x = [[vertsArray objectAtIndex:i*3] floatValue] + xOffset;
		pVert->y = [[vertsArray objectAtIndex:(i*3)+1] floatValue] + yOffset;
		pVert->z = [[vertsArray objectAtIndex:(i*3)+2] floatValue] + zOffset;
	}	

	if (debugColor) {
		float red, green, blue, alpha;
		[debugColor getRed:&red green:&green blue:&blue alpha:&alpha];
		mesh.diffuseColor = FCColor4f( red, green, blue, alpha );
	}
	else
	{
		mesh.diffuseColor = s_whiteColor;
	}

	unsigned short* pIndex;
	
	for (int i = 0; i < mesh.numTriangles; i++)
	{
		pIndex = [mesh pIndexBufferAtIndex:i*3];
		*pIndex = 0;
		*(pIndex+1) = i+1;
		*(pIndex+2) = i+2;
	}
}

@end

#endif // defined(FC_GRAPHICS)
