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

#import <Foundation/Foundation.h>

enum FCVertexDescriptorPropertyType {
	kFCVertexDescriptorPropertyTypeAbsent = 0,
	
	kFCVertexDescriptorPropertyTypeUniformFloat,
	kFCVertexDescriptorPropertyTypeUniformVec2,
	kFCVertexDescriptorPropertyTypeUniformVec3,
	kFCVertexDescriptorPropertyTypeUniformVec4,
	kFCVertexDescriptorPropertyTypeUniformInt,
	kFCVertexDescriptorPropertyTypeUniformIVec2,
	kFCVertexDescriptorPropertyTypeUniformIVec3,
	kFCVertexDescriptorPropertyTypeUniformIVec4,
	kFCVertexDescriptorPropertyTypeUniformBool,
	kFCVertexDescriptorPropertyTypeUniformBVec2,
	kFCVertexDescriptorPropertyTypeUniformBVec3,
	kFCVertexDescriptorPropertyTypeUniformBVec4,
	kFCVertexDescriptorPropertyTypeUniformMat2,
	kFCVertexDescriptorPropertyTypeUniformMat3,
	kFCVertexDescriptorPropertyTypeUniformMat4,
	
	kFCVertexDescriptorPropertyFirstAttribute,
	kFCVertexDescriptorPropertyTypeAttributeFloat,
	kFCVertexDescriptorPropertyTypeAttributeVec2,
	kFCVertexDescriptorPropertyTypeAttributeVec3,
	kFCVertexDescriptorPropertyTypeAttributeVec4,
	kFCVertexDescriptorPropertyTypeAttributeInt,
	kFCVertexDescriptorPropertyTypeAttributeIVec2,
	kFCVertexDescriptorPropertyTypeAttributeIVec3,
	kFCVertexDescriptorPropertyTypeAttributeIVec4,
	kFCVertexDescriptorPropertyTypeAttributeBool,
	kFCVertexDescriptorPropertyTypeAttributeBVec2,
	kFCVertexDescriptorPropertyTypeAttributeBVec3,
	kFCVertexDescriptorPropertyTypeAttributeBVec4,
	kFCVertexDescriptorPropertyTypeAttributeMat2,
	kFCVertexDescriptorPropertyTypeAttributeMat3,
	kFCVertexDescriptorPropertyTypeAttributeMat4,
	kFCVertexDescriptorPropertyLastAttribute,
	kFCVertexDescriptorLastProperty
};

@interface FCVertexDescriptor : NSObject {
	NSString*						_name;
	FCVertexDescriptorPropertyType	_positionType;
	FCVertexDescriptorPropertyType	_diffuseColorType;
	FCVertexDescriptorPropertyType	_normalType;
	FCVertexDescriptorPropertyType	_tex0Type;
	FCVertexDescriptorPropertyType	_tex1Type;
	FCVertexDescriptorPropertyType	_tex2Type;
	FCVertexDescriptorPropertyType	_tex3Type;
	unsigned int					_stride;
	unsigned int					_positionOffset;
	unsigned int					_diffuseColorOffset;
	unsigned int					_normalOffset;
	unsigned int					_tex0Offset;
	unsigned int					_tex1Offset;
	unsigned int					_tex2Offset;
	unsigned int					_tex3Offset;
}
@property(nonatomic, strong) NSString* name;
@property(nonatomic) FCVertexDescriptorPropertyType positionType;
@property(nonatomic) FCVertexDescriptorPropertyType diffuseColorType;
@property(nonatomic) FCVertexDescriptorPropertyType normalType;
@property(nonatomic) FCVertexDescriptorPropertyType tex0Type;
@property(nonatomic) FCVertexDescriptorPropertyType tex1Type;
@property(nonatomic) FCVertexDescriptorPropertyType tex2Type;
@property(nonatomic) FCVertexDescriptorPropertyType tex3Type;
@property(nonatomic) unsigned int stride;
@property(nonatomic, readonly) unsigned int positionOffset;
@property(nonatomic, readonly) unsigned int diffuseColorOffset;
@property(nonatomic, readonly) unsigned int normalOffset;
@property(nonatomic, readonly) unsigned int tex0Offset;
@property(nonatomic, readonly) unsigned int tex1Offset;
@property(nonatomic, readonly) unsigned int tex2Offset;
@property(nonatomic, readonly) unsigned int tex3Offset;

-(id)init;
+(id)vertexDescriptor;

-(id)initWithVertexFormatString:(NSString*)desc andUniformDict:(NSDictionary*)uniformDict;
+(id)vertexDescriptorWithVertexFormatString:(NSString*)desc andUniformDict:(NSDictionary*)uniformDict;

-(BOOL)canSatisfy:(FCVertexDescriptor*)desc;

@end

