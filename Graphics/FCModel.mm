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

//#import "FCCategories.h"
#import "FCModel.h"
#import "FCMaths.h"
#import "FCKeys.h"
#import "FCXMLData.h"
#import "FCMesh.h"
#import "FCResource.h"
#import "FCShaderManager.h"
#import "FCShaderProgram.h"
#import "FCRenderer.h"

static 	FC::Color4f	s_whiteColor( 1.0f, 1.0f, 1.0f, 1.0f );
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

-(id)initWithPhysicsBody:(NSDictionary *)bodyDict color:(UIColor*)color	//actorXOffset:(float)actorX actorYOffset:(float)actorY
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
			
			float fixtureX = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]] floatValue];// + actorX;
			float fixtureY = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]] floatValue];// + actorY;
			float fixtureZ = [[fixture valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetZ.c_str()]] floatValue];// + actorZ;
			
			if ([type isEqualToString:@"box"]) 
			{
				// box
				NSMutableDictionary* debugDict = [[NSMutableDictionary alloc] init];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureX] forKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureY] forKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureZ] forKey:[NSString stringWithUTF8String:kFCKeyOffsetZ.c_str()]];
				[debugDict setValue:[fixture valueForKey:@"xSize"] forKey:[NSString stringWithUTF8String:kFCKeyXSize.c_str()]];
				[debugDict setValue:[fixture valueForKey:@"ySize"] forKey:[NSString stringWithUTF8String:kFCKeyYSize.c_str()]];
				[debugDict setValue:[fixture valueForKey:@"zSize"] forKey:[NSString stringWithUTF8String:kFCKeyZSize.c_str()]];
				
				[self addDebugRectangle:debugDict color:color];
			} 
			else if([type isEqualToString:@"circle"]) 
			{
				// circle
				NSMutableDictionary* debugDict = [[NSMutableDictionary alloc] init];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureX] forKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureY] forKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]];
				[debugDict setValue:[NSNumber numberWithFloat:fixtureZ] forKey:[NSString stringWithUTF8String:kFCKeyOffsetZ.c_str()]];
				[debugDict setValue:[fixture valueForKey:@"radius"] forKey:[NSString stringWithUTF8String:kFCKeyRadius.c_str()]];
				
				[self addDebugCircle:debugDict color:color];				
			} 
			else if([type isEqualToString:@"hull"]) 
			{
				// polygon
				NSMutableDictionary* debugDict = [[NSMutableDictionary alloc] init];

				NSString* strippedVerts = [fixture valueForKey:@"verts"];
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

-(id)initWithModel:(NSDictionary*)modelDict resource:(FCResource*)res
{
	self = [super init];
	if (self) 
	{
		NSArray* meshArray;
		id val = [modelDict valueForKey:[NSString stringWithUTF8String:kFCKeyMesh.c_str()]];

		if ([val isKindOfClass:[NSArray class]]) {
			meshArray = val;
		} else {
			meshArray = [NSArray arrayWithObject:val];
		}

		NSArray* binaryPayloadArray = [res.xmlData arrayForKeyPath:@"fcr.binarypayload.chunk"];

		self.meshes = [NSMutableArray array];
		
		for( NSDictionary* mesh in meshArray )
		{
			NSString* shaderName = [mesh valueForKey:[NSString stringWithUTF8String:kFCKeyShader.c_str()]];
			
			NSString* indexBufferId = [mesh valueForKey:[NSString stringWithUTF8String:kFCKeyIndexBuffer.c_str()]];
			NSString* vertexBufferId = [mesh valueForKey:[NSString stringWithUTF8String:kFCKeyVertexBuffer.c_str()]];

			NSDictionary* indexBufferDict = nil;
			NSDictionary* vertexBufferDict = nil;
			
			for( NSDictionary* chunk in binaryPayloadArray )
			{
				if ([[chunk valueForKey:[NSString stringWithUTF8String:kFCKeyId.c_str()]] isEqualToString:indexBufferId]) {
					indexBufferDict = chunk;
				}
				if ([[chunk valueForKey:[NSString stringWithUTF8String:kFCKeyId.c_str()]] isEqualToString:vertexBufferId]) {
					vertexBufferDict = chunk;
				}
			}
			
			FC_ASSERT( indexBufferDict && vertexBufferDict );
			
			// all looks good so far - lets build the mesh

//			FCVertexDescriptor* vertexDescriptor = [FCVertexDescriptor vertexDescriptorForShader:shaderName];
			
			GLenum primitiveType = GL_TRIANGLES;
			
			if ([shaderName isEqualToString:[NSString stringWithUTF8String:kFCKeyShaderWireframe.c_str()]]) {
				primitiveType = GL_LINES;
			}
			
			FCMesh* meshObject = [[FCMesh alloc] initWithVertexDescriptor:nil 
															   shaderName:shaderName
															primitiveType:primitiveType];
			
			
			meshObject.numVertices = [[mesh valueForKey:[NSString stringWithUTF8String:kFCKeyNumVertices.c_str()]] intValue];
			meshObject.numTriangles = [[mesh valueForKey:[NSString stringWithUTF8String:kFCKeyNumTriangles.c_str()]] intValue];
			meshObject.numEdges = [[mesh valueForKey:[NSString stringWithUTF8String:kFCKeyNumEdges.c_str()]] intValue];
			
			// specular color
			
			if ([mesh valueForKey:@"specular_r"] && [mesh valueForKey:@"specular_g"] && [mesh valueForKey:@"specular_b"]) {
				FC::Color4f specular;
				specular.r = [[mesh valueForKey:@"specular_r"] floatValue];
				specular.g = [[mesh valueForKey:@"specular_g"] floatValue];
				specular.b = [[mesh valueForKey:@"specular_b"] floatValue];
				specular.a = 1.0f;
				meshObject.specularColor = specular;
			}
			
			// copy across vertex and index buffers

			NSUInteger indexBufferOffset = [[indexBufferDict valueForKey:@"offset"] intValue];
			NSUInteger indexBufferSize = [[indexBufferDict valueForKey:@"size"] intValue];
			[res.binaryPayload getBytes:meshObject.pIndexBuffer range:NSMakeRange(indexBufferOffset, indexBufferSize)];
			
			NSUInteger vertexBufferOffset = [[vertexBufferDict valueForKey:@"offset"] intValue];
			NSUInteger vertexBufferSize = [[vertexBufferDict valueForKey:@"size"] intValue];
			[res.binaryPayload getBytes:meshObject.pVertexBuffer range:NSMakeRange(vertexBufferOffset, vertexBufferSize)];
					
			NSString* diffuseString = [mesh valueForKey:[NSString stringWithUTF8String:kFCKeyDiffuseColor.c_str()]];
			if (diffuseString) {
				NSArray* components = [diffuseString componentsSeparatedByString:@","];
				meshObject.diffuseColor = FC::Color4f([[components objectAtIndex:0] floatValue], 
													  [[components objectAtIndex:1] floatValue], 
													  [[components objectAtIndex:2] floatValue], 1.0f );
			}

			meshObject.parentModel = self;
			[self.meshes addObject:meshObject];
		}
	}
	return self;
}

//-(void)render
//{
	// Remove this function entirely since rendering and sorting is done by mesh

//	FC::Matrix4f mat = FC::Matrix4f::Identity();
//	FC::Matrix4f trans = FC::Matrix4f::Translate(self.position.x, self.position.y, 0.0f);
//	FC::Matrix4f rot = FC::Matrix4f::Rotate(self.rotation, FC::Vector3f(0.0f, 0.0f, -1.0f) );
//
//	FC::Vector3f lightDirection( 0.707f, 0.707f, 0.707f );
//
//	FC::Vector3f invLight = lightDirection * rot;
//	
//	mat = rot * trans;
//		
//	GLuint lastShaderProgram = 99999;
//	
//	for (FCMesh* mesh in self.meshes) 
//	{
//		if (lastShaderProgram != mesh.shaderProgram.glHandle) 
//		{
//			FCShaderUniform* uniform = [mesh.shaderProgram getUniform:@"modelview"];		
//			[mesh.shaderProgram setUniformValue:uniform to:&mat size:sizeof(mat)];
//			
//			uniform = [mesh.shaderProgram getUniform:@"light_direction"];
//			if (uniform) {
//				[mesh.shaderProgram setUniformValue:uniform to:&invLight size:sizeof(invLight)];
//			}
//			lastShaderProgram = mesh.shaderProgram.glHandle;
//		}
//		[mesh render];
//	}
//}

-(void)setDebugMeshColor:(FC::Color4f)color
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
	
	FC::Vector3f* pVert;
	FC::Vector3f center;
	center.x = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]] floatValue];
	center.y = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]] floatValue];
	center.z = 0.0f;

	pVert = (FC::Vector3f*)((unsigned long)mesh.pVertexBuffer);
	pVert->x = center.x;
	pVert->y = center.y;
	pVert->z = center.z;

	for( int i = 0 ; i < kNumCircleSegments ; i++ )
	{		
		float angle1 = ( 3.142f * 2.0f / kNumCircleSegments ) * i;
		
		pVert = (FC::Vector3f*)((unsigned int)pVert + 12);
		
		pVert->x = center.x + sinf( angle1 ) * radius;
		pVert->y = center.y + cosf( angle1 ) * radius;
		pVert->z = center.z;		
	}

	if (debugColor) {
		float red, green, blue, alpha;
		[debugColor getRed:&red green:&green blue:&blue alpha:&alpha];
		mesh.diffuseColor = FC::Color4f( red, green, blue, alpha );
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
//	FCMesh* mesh = [FCMesh fcMeshWithVertexDescriptor:[FCVertexDescriptor vertexDescriptorForShader:kFCKeyShaderWireframe] shaderName:kFCKeyShaderWireframe];
	[self.meshes addObject:mesh];
	mesh.parentModel = self;

	mesh.numVertices = 4;
	mesh.numTriangles = 2;
	
	FC::Vector2f size( [[def valueForKey:[NSString stringWithUTF8String:kFCKeyXSize.c_str()]] floatValue] * 0.5f, 
					  [[def valueForKey:[NSString stringWithUTF8String:kFCKeyYSize.c_str()]] floatValue] * 0.5f);

	FC::Vector3f center;
	center.x = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]] floatValue];
	center.y = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]] floatValue];
	center.z = 0.0f;

	FC::Vector3f* pVert;
	
	pVert = (FC::Vector3f*)((unsigned long)mesh.pVertexBuffer);
	pVert->x = center.x + size.x * -1.0f;
	pVert->y = center.y + size.y * -1.0f;
	pVert->z = center.z;
	
	pVert = (FC::Vector3f*)((unsigned int)pVert + 12);
	pVert->x = center.x + size.x * 1.0f;
	pVert->y = center.y + size.y * -1.0f;
	pVert->z = center.z;
	
	pVert = (FC::Vector3f*)((unsigned int)pVert + 12);
	pVert->x = center.x + size.x * 1.0f;
	pVert->y = center.y + size.y * 1.0f;
	pVert->z = center.z;
	
	pVert = (FC::Vector3f*)((unsigned int)pVert + 12);
	pVert->x = center.x + size.x * -1.0f;
	pVert->y = center.y + size.y * 1.0f;
	pVert->z = center.z;
	
	if (debugColor) {
		float red, green, blue, alpha;
		[debugColor getRed:&red green:&green blue:&blue alpha:&alpha];
		mesh.diffuseColor = FC::Color4f( red, green, blue, alpha );
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
//	FCMesh* mesh = [FCMesh fcMeshWithVertexDescriptor:[FCVertexDescriptor vertexDescriptorForShader:kFCKeyShaderWireframe] shaderName:kFCKeyShaderWireframe];
	[self.meshes addObject:mesh];
	mesh.parentModel = self;

	mesh.numVertices = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyNumVertices.c_str()]] intValue];
	mesh.numTriangles = mesh.numVertices - 2;
	
	FC::Vector3f* pVert;

	NSArray* vertsArray = [[def valueForKeyPath:@"verts"] componentsSeparatedByString:@" "];

	pVert = (FC::Vector3f*)((unsigned long)mesh.pVertexBuffer);
	
	float xOffset = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetX.c_str()]] floatValue];
	float yOffset = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetY.c_str()]] floatValue];
	float zOffset = [[def valueForKey:[NSString stringWithUTF8String:kFCKeyOffsetZ.c_str()]] floatValue];
	
	pVert->x = [[vertsArray objectAtIndex:0] floatValue] + xOffset;
	pVert->y = [[vertsArray objectAtIndex:1] floatValue] + yOffset;
	pVert->z = [[vertsArray objectAtIndex:2] floatValue] + zOffset;

	for (int i = 1 ; i < mesh.numVertices ; i++) 
	{
		pVert = (FC::Vector3f*)((unsigned int)pVert + 12);
		pVert->x = [[vertsArray objectAtIndex:i*3] floatValue] + xOffset;
		pVert->y = [[vertsArray objectAtIndex:(i*3)+1] floatValue] + yOffset;
		pVert->z = [[vertsArray objectAtIndex:(i*3)+2] floatValue] + zOffset;
	}	

	if (debugColor) {
		float red, green, blue, alpha;
		[debugColor getRed:&red green:&green blue:&blue alpha:&alpha];
		mesh.diffuseColor = FC::Color4f( red, green, blue, alpha );
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
