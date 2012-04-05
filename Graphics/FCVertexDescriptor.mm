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

#import "FCVertexDescriptor.h"
#import "FCCore.h"

static NSString* s_nameForProperty[ kFCVertexDescriptorLastProperty ] = {
	@"Absent",
	@"Uniform Float",
	@"Uniform Vec 2",
	@"Uniform Vec 3",
	@"Uniform Vec 4",
	@"Uniform Int",
	@"Uniform IVec2",
	@"Uniform IVec3",
	@"Uniform IVec4",
	@"Uniform Bool",
	@"Uniform BVec2",
	@"Uniform BVec3",
	@"Uniform BVec4",
	@"Uniform Mat2",
	@"Uniform Mat3",
	@"Uniform Mat4",
	@"First Attribute",
	@"Attribute Float",
	@"Attribute Vec2",
	@"Attribute Vec3",
	@"Attribute Vec4",
	@"Attribute Int",
	@"Attribute IVec2",
	@"Attribute IVec3",
	@"Attribute IVec4",
	@"Attribute Bool",
	@"Attribute BVec2",
	@"Attribute BVec3",
	@"Attribute BVec4",
	@"Attribute Mat2",
	@"Attribute Mat3",
	@"Attribute Mat4",
	@"Last Attribute"
};

static NSMutableDictionary* s_dictionary;

@interface FCVertexDescriptor()
-(unsigned int)sizeForType:(FCVertexDescriptorPropertyType)type;
@end

@implementation FCVertexDescriptor
@synthesize name = _name;
@synthesize positionType = _positionType;
@synthesize diffuseColorType = _diffuseColorType;
@synthesize normalType = _normalType;
@synthesize tex0Type = _tex0Type;
@synthesize tex1Type = _tex1Type;
@synthesize tex2Type = _tex2Type;
@synthesize tex3Type = _tex3Type;
@synthesize stride = _stride;
@synthesize positionOffset = _positionOffset;
@synthesize diffuseColorOffset = _diffuseColorOffset;
@synthesize normalOffset = _normalOffset;
@synthesize tex0Offset = _tex0Offset;
@synthesize tex1Offset = _tex1Offset;
@synthesize tex2Offset = _tex2Offset;
@synthesize tex3Offset = _tex3Offset;

+(void)initialize
{
	s_dictionary = [[NSMutableDictionary alloc] init];
	
	FCVertexDescriptor* wireframe = [[FCVertexDescriptor alloc] init];
	wireframe.positionType = kFCVertexDescriptorPropertyTypeAttributeVec3;
	wireframe.diffuseColorType = kFCVertexDescriptorPropertyTypeUniformVec4;
	[s_dictionary setValue:wireframe forKey:kFCKeyShaderWireframe];
}

-(id)init
{
	self = [super init];
	if (self) {
		self.positionType = kFCVertexDescriptorPropertyTypeAbsent;
		self.diffuseColorType = kFCVertexDescriptorPropertyTypeAbsent;
		self.normalType = kFCVertexDescriptorPropertyTypeAbsent;
		self.tex0Type = kFCVertexDescriptorPropertyTypeAbsent;
		self.tex1Type = kFCVertexDescriptorPropertyTypeAbsent;
		self.tex2Type = kFCVertexDescriptorPropertyTypeAbsent;
		self.tex3Type = kFCVertexDescriptorPropertyTypeAbsent;
	}
	return self;
}

+(id)vertexDescriptorForShader:(NSString *)shader
{
	return [s_dictionary valueForKey:shader];
}

//-(id)initWithVertexFormatString:(NSString *)desc andUniformDict:(NSDictionary *)uniformDict
//{
//	self = [self init];
//	
//	// Uniforms
//
//	NSString* diffuseColorValue = [uniformDict valueForKey:kFCKeyMaterialDiffuseColor];
//	
//	if (diffuseColorValue) {
//		NSArray* elementArray = [diffuseColorValue componentsSeparatedByString:@" "];
//		if ([elementArray count] == 3) {
//			self.diffuseColorType = kFCVertexDescriptorPropertyTypeUniformVec3;
//		} else if ([elementArray count] == 4) {
//			self.diffuseColorType = kFCVertexDescriptorPropertyTypeUniformVec4;			
//		} else {
//			FC_FATAL(@"Diffuse color with other than 3 or 4 components");
//		}
//	}
//
//	// Attributes
//
//	NSArray* attributeArray = [desc componentsSeparatedByString:@","];
//	
//	for( NSString* attributeString in attributeArray ) {
//		NSRange leftBracketRange = [attributeString rangeOfString:@"("];
//		NSRange rightBracketRange = [attributeString rangeOfString:@")"];
//
//		NSRange nameRange;
//		nameRange.location = 0;
//		nameRange.length = leftBracketRange.location;
//		
//		NSRange typeRange;
//		typeRange.location = leftBracketRange.location + 1;
//		typeRange.length = rightBracketRange.location - leftBracketRange.location - 1;
//		
//		NSString* attrNameString = [attributeString substringWithRange:nameRange];
//		NSString* attrTypeString = [attributeString substringWithRange:typeRange];
//		
//		NSLog(@"%@ %@", attrNameString, attrTypeString);
//	}
//							   
//	return self;
//}

//+(id)vertexDescriptorWithVertexFormatString:(NSString *)desc andUniformDict:(NSDictionary *)uniformDict
//{
//	return [[FCVertexDescriptor alloc] initWithVertexFormatString:desc andUniformDict:uniformDict];
//}

//-(BOOL)canSatisfy:(FCVertexDescriptor*)desc
//{
//	return NO;
//}

-(unsigned int)stride
{
	// cache this

	if (_stride == 0) {
		_positionOffset = _stride;
		_stride += [self sizeForType:self.positionType];
		_stride += [self sizeForType:self.diffuseColorType];
		_stride += [self sizeForType:self.normalType];
		_stride += [self sizeForType:self.tex0Type];
		_stride += [self sizeForType:self.tex1Type];
		_stride += [self sizeForType:self.tex2Type];
		_stride += [self sizeForType:self.tex3Type];
	}

	return _stride;
}

-(unsigned int)sizeForType:(FCVertexDescriptorPropertyType)type
{
	switch (type) 
	{
		case kFCVertexDescriptorPropertyTypeAttributeFloat: return 4;
		case kFCVertexDescriptorPropertyTypeAttributeVec2: return 8;
		case kFCVertexDescriptorPropertyTypeAttributeVec3: return 12;
		case kFCVertexDescriptorPropertyTypeAttributeVec4: return 16;
		case kFCVertexDescriptorPropertyTypeAttributeInt: return 4;
		case kFCVertexDescriptorPropertyTypeAttributeIVec2: return 8;
		case kFCVertexDescriptorPropertyTypeAttributeIVec3: return 12;
		case kFCVertexDescriptorPropertyTypeAttributeIVec4: return 16;
		case kFCVertexDescriptorPropertyTypeAttributeBool: return 4;
		case kFCVertexDescriptorPropertyTypeAttributeBVec2: return 8;
		case kFCVertexDescriptorPropertyTypeAttributeBVec3: return 12;
		case kFCVertexDescriptorPropertyTypeAttributeBVec4: return 16;
		case kFCVertexDescriptorPropertyTypeAttributeMat2: return 16;
		case kFCVertexDescriptorPropertyTypeAttributeMat3: return 36;
		case kFCVertexDescriptorPropertyTypeAttributeMat4: return 64;
			
		default:
			return 0;
	}
}

-(unsigned int) positionOffset
{
	FC_ASSERT(self.positionType > kFCVertexDescriptorPropertyFirstAttribute);
	FC_ASSERT(self.positionType < kFCVertexDescriptorPropertyLastAttribute);
	
	(void)self.stride;
	return _positionOffset;
}

-(unsigned int) diffuseColorOffset
{
//	FC_ASSERT(self.diffuseColorType > kFCVertexDescriptorPropertyFirstAttribute);
//	FC_ASSERT(self.diffuseColorType < kFCVertexDescriptorPropertyLastAttribute);
	
	(void)self.stride;
	return _diffuseColorOffset;
}

-(unsigned int) normalOffset
{
	FC_ASSERT(self.normalType > kFCVertexDescriptorPropertyFirstAttribute);
	FC_ASSERT(self.normalType < kFCVertexDescriptorPropertyLastAttribute);
	
	(void)self.stride;
	return _normalOffset;
}

-(unsigned int) tex0Offset
{
	FC_ASSERT(self.tex0Type > kFCVertexDescriptorPropertyFirstAttribute);
	FC_ASSERT(self.tex0Type < kFCVertexDescriptorPropertyLastAttribute);
	
	(void)self.stride;
	return _tex0Offset;
}

-(unsigned int) tex1Offset
{
	FC_ASSERT(self.tex1Type > kFCVertexDescriptorPropertyFirstAttribute);
	FC_ASSERT(self.tex1Type < kFCVertexDescriptorPropertyLastAttribute);
	
	(void)self.stride;
	return _tex1Offset;
}

-(unsigned int) tex2Offset
{
	FC_ASSERT(self.tex2Type > kFCVertexDescriptorPropertyFirstAttribute);
	FC_ASSERT(self.tex2Type < kFCVertexDescriptorPropertyLastAttribute);
	
	(void)self.stride;
	return _tex2Offset;
}

-(unsigned int) tex3Offset
{
	FC_ASSERT(self.tex3Type > kFCVertexDescriptorPropertyFirstAttribute);
	FC_ASSERT(self.tex3Type < kFCVertexDescriptorPropertyLastAttribute);
	
	(void)self.stride;
	return _tex3Offset;
}

#if !defined (MASTER)
-(NSString*)description
{
	NSMutableString* retString = [NSMutableString string];
	[retString appendString:@"--- FCVertexDescriptor"];
	[retString appendFormat:@"Name: %@", self.name];
	[retString appendFormat:@"Stride: %@", self.stride];
	
	if (self.positionType != kFCVertexDescriptorPropertyTypeAbsent) {
		[retString appendFormat:@"Position: %@, %d", s_nameForProperty[ self.positionType ], self.positionOffset ];
	}

	if (self.diffuseColorType != kFCVertexDescriptorPropertyTypeAbsent) {
		[retString appendFormat:@"Diffuse Color: %@, %d", s_nameForProperty[ self.diffuseColorType ], self.diffuseColorOffset ];
	}

	if (self.normalType != kFCVertexDescriptorPropertyTypeAbsent) {
		[retString appendFormat:@"Normal: %@, %d", s_nameForProperty[ self.normalType ], self.normalOffset ];
	}

	if (self.tex0Type != kFCVertexDescriptorPropertyTypeAbsent) {
		[retString appendFormat:@"Tex0: %@, %d", s_nameForProperty[ self.tex0Type ], self.tex0Offset ];
	}

	if (self.tex1Type != kFCVertexDescriptorPropertyTypeAbsent) {
		[retString appendFormat:@"Tex1: %@, %d", s_nameForProperty[ self.tex1Type ], self.tex1Offset ];
	}

	if (self.tex2Type != kFCVertexDescriptorPropertyTypeAbsent) {
		[retString appendFormat:@"Tex2: %@, %d", s_nameForProperty[ self.tex2Type ], self.tex2Offset ];
	}

	if (self.tex3Type != kFCVertexDescriptorPropertyTypeAbsent) {
		[retString appendFormat:@"Tex3: %@, %d", s_nameForProperty[ self.tex3Type ], self.tex3Offset ];
	}

	return [NSString stringWithString:retString];
}
#endif

@end

#endif // defined(FC_GRAPHICS)
