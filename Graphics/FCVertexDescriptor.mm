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

#import "FCVertexDescriptor.h"
#import "FCCore.h"

@interface FCVertexDescriptor()
-(unsigned int)sizeForType:(FCVertexDescriptorPropertyType)type;
@end

@implementation FCVertexDescriptor
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
	FC_ASSERT(self.diffuseColorType > kFCVertexDescriptorPropertyFirstAttribute);
	FC_ASSERT(self.diffuseColorType < kFCVertexDescriptorPropertyLastAttribute);
	
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

@end
