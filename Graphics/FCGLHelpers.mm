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

#import "FCError.h"
#import "FCGLHelpers.h"

void FCGLCheckErrors( void )
{
	GLenum error = glGetError();
	
	if( error == GL_NO_ERROR )
		return;
	
	switch (error) {
		case GL_INVALID_ENUM:
			FC_FATAL(@"GL_INVALID_ENUM");
			break;
		case GL_INVALID_VALUE:
			FC_FATAL(@"GL_INVALID_VALUE");
			break;
		case GL_INVALID_OPERATION:
			FC_FATAL(@"GL_INVALID_OPERATION");
			break;
		case GL_OUT_OF_MEMORY:
			FC_FATAL(@"GL_OUT_OF_MEMORY");
			break;
		default:
			break;
	}
	exit(1);
}

#pragma mark - Versions

NSString* FCGLQueryVendor( void )
{
	const GLubyte* pString = glGetString(GL_VENDOR);
	return [NSString stringWithFormat:@"%s", pString];
}

NSString* FCGLQueryVersion( void )
{
	const GLubyte* pString = glGetString(GL_VERSION);
	return [NSString stringWithFormat:@"%s", pString];	
}

NSString* FCGLQueryRenderer( void )
{
	const GLubyte* pString = glGetString(GL_RENDERER);
	return [NSString stringWithFormat:@"%s", pString];	
}

NSString* FCGLQueryShadingLanguageVersion( void )
{
	const GLubyte* pString = glGetString(GL_SHADING_LANGUAGE_VERSION);
	return [NSString stringWithFormat:@"%s", pString];	
}

NSArray* FCGLQueryExtensions( void )
{
	const GLubyte* pString = glGetString(GL_EXTENSIONS);
	NSString* nsString = [NSString stringWithFormat:@"%s", pString];
	return [nsString componentsSeparatedByString:@" "];
}

void FCGLLogVersions( void )
{
	FC_LOG(@"---OpenGL Versions---");
	FC_LOG1(@"Vendor:%@", FCGLQueryVendor());
	FC_LOG1(@"Version:%@", FCGLQueryVersion());
	FC_LOG1(@"Renderer:%@", FCGLQueryRenderer());
	FC_LOG1(@"Shading language version:%@", FCGLQueryShadingLanguageVersion());
	FC_LOG1(@"Extensions:%@", FCGLQueryExtensions());
}

#pragma mark - Caps

void FCGLLogCaps( void )
{
	NSString* tempString;
	GLint intValue[16];
	GLfloat floatValue[16];
	
	FC_LOG(@"---OpenGL Caps---");
	
	glGetIntegerv(GL_SUBPIXEL_BITS, intValue);
	tempString = [NSString stringWithFormat:@"GL_SUBPIXEL_BITS: %d", intValue[0]];
	FC_LOG(tempString);
	
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, intValue);
	tempString = [NSString stringWithFormat:@"GL_MAX_TEXTURE_SIZE: %d",intValue[0]];
	FC_LOG(tempString);
	
	glGetIntegerv(GL_MAX_CUBE_MAP_TEXTURE_SIZE, intValue);
	tempString = [NSString stringWithFormat:@"GL_MAX_CUBE_MAP_TEXTURE_SIZE: %d", intValue[0]];
	FC_LOG(tempString);
	
	glGetIntegerv(GL_MAX_VIEWPORT_DIMS, intValue);
	tempString = [NSString stringWithFormat:@"GL_MAX_VIEWPORT_DIMS: %d %d", intValue[0], intValue[1]];
	FC_LOG(tempString);
	
	glGetFloatv(GL_ALIASED_POINT_SIZE_RANGE, floatValue);
	tempString = [NSString stringWithFormat:@"GL_ALIASED_POINT_SIZE_RANGE: %f %f", floatValue[0], floatValue[1]];
	FC_LOG(tempString);
	
	glGetFloatv(GL_ALIASED_LINE_WIDTH_RANGE, floatValue);
	tempString = [NSString stringWithFormat:@"GL_ALIASED_LINE_WIDTH_RANGE: %f %f", floatValue[0], floatValue[1]];
	FC_LOG(tempString);
	
	glGetIntegerv(GL_NUM_COMPRESSED_TEXTURE_FORMATS, intValue);
	int numCompressedTextureFormats = intValue[0];
	tempString = [NSString stringWithFormat:@"GL_NUM_COMPRESSED_TEXTURE_FORMATS: %d", intValue[0]];
	FC_LOG(tempString);

	glGetIntegerv(GL_COMPRESSED_TEXTURE_FORMATS, intValue);
	for (int i = 0; i < numCompressedTextureFormats; i++) {
		// blah
		NSString* format = FCGLStringForEnum(intValue[i]);
		FC_LOG(format);
	}
	
	glGetIntegerv(GL_RED_BITS, intValue);
	tempString = [NSString stringWithFormat:@"GL_RED_BITS: %d", intValue[0]];
	FC_LOG(tempString);
	
	glGetIntegerv(GL_GREEN_BITS, intValue);
	tempString = [NSString stringWithFormat:@"GL_GREEN_BITS: %d", intValue[0]];
	FC_LOG(tempString);

	glGetIntegerv(GL_BLUE_BITS, intValue);
	tempString = [NSString stringWithFormat:@"GL_BLUE_BITS: %d", intValue[0]];
	FC_LOG(tempString);

	glGetIntegerv(GL_ALPHA_BITS, intValue);
	tempString = [NSString stringWithFormat:@"GL_ALPHA_BITS: %d", intValue[0]];
	FC_LOG(tempString);

	glGetIntegerv(GL_DEPTH_BITS, intValue);
	tempString = [NSString stringWithFormat:@"GL_DEPTH_BITS: %d", intValue[0]];
	FC_LOG(tempString);

	glGetIntegerv(GL_STENCIL_BITS, intValue);
	tempString = [NSString stringWithFormat:@"GL_STENCIL_BITS: %d", intValue[0]];
	FC_LOG(tempString);

	glGetIntegerv(GL_MAX_VERTEX_UNIFORM_VECTORS, intValue);
	tempString = [NSString stringWithFormat:@"GL_MAX_VERTEX_UNIFORM_VECTORS: %d", intValue[0]];
	FC_LOG(tempString);

	glGetIntegerv(GL_MAX_FRAGMENT_UNIFORM_VECTORS, intValue);
	tempString = [NSString stringWithFormat:@"GL_MAX_FRAGMENT_UNIFORM_VECTORS: %d", intValue[0]];
	FC_LOG(tempString);

	glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, intValue);
	tempString = [NSString stringWithFormat:@"GL_MAX_VERTEX_ATTRIBS: %d", intValue[0]];
	FC_LOG(tempString);

	glGetIntegerv(GL_MAX_VARYING_VECTORS, intValue);
	tempString = [NSString stringWithFormat:@"GL_MAX_VARYING_VECTORS: %d", intValue[0]];
	FC_LOG(tempString);

	glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, intValue);
	tempString = [NSString stringWithFormat:@"GL_MAX_TEXTURE_IMAGE_UNITS: %d", intValue[0]];
	FC_LOG(tempString);
}

NSString* FCGLStringForEnum( GLenum thisEnum )
{
	switch ( thisEnum ) {
		case GL_ACTIVE_ATTRIBUTE_MAX_LENGTH: return @"GL_ACTIVE_ATTRIBUTE_MAX_LENGTH"; break;
		case GL_ACTIVE_ATTRIBUTES: return @"GL_ACTIVE_ATTRIBUTES"; break;
		case GL_ACTIVE_PROGRAM_EXT: return @"GL_ACTIVE_PROGRAM_EXT"; break;
		case GL_ACTIVE_TEXTURE: return @"GL_ACTIVE_TEXTURE"; break;
		case GL_ACTIVE_UNIFORM_MAX_LENGTH: return @"GL_ACTIVE_UNIFORM_MAX_LENGTH"; break;
		case GL_ACTIVE_UNIFORMS: return @"GL_ACTIVE_UNIFORMS"; break;
		case GL_ALIASED_LINE_WIDTH_RANGE: return @"GL_ALIASED_LINE_WIDTH_RANGE"; break;
		case GL_ALIASED_POINT_SIZE_RANGE: return @"GL_ALIASED_POINT_SIZE_RANGE"; break;
		case GL_ALL_SHADER_BITS_EXT: return @"GL_ALL_SHADER_BITS_EXT"; break;
		case GL_ALPHA: return @"GL_ALPHA"; break;
		case GL_ALPHA_BITS: return @"GL_ALPHA_BITS"; break;
		case GL_ALWAYS: return @"GL_ALWAYS"; break;
		case GL_ANY_SAMPLES_PASSED_CONSERVATIVE_EXT: return @"GL_ANY_SAMPLES_PASSED_CONSERVATIVE_EXT"; break;
		case GL_ANY_SAMPLES_PASSED_EXT: return @"GL_ANY_SAMPLES_PASSED_EXT"; break;
//		case GL_API: return @"GL_API"; break;
//		case GL_APIENTRY: return @"GL_APIENTRY"; break;
//		case GL_APIENTRYP: return @"GL_APIENTRYP"; break;
		case GL_ARRAY_BUFFER: return @"GL_ARRAY_BUFFER"; break;
		case GL_ARRAY_BUFFER_BINDING: return @"GL_ARRAY_BUFFER_BINDING"; break;
		case GL_ATTACHED_SHADERS: return @"GL_ATTACHED_SHADERS"; break;
			
		case GL_BACK: return @"GL_BACK"; break;
		case GL_BGRA: return @"GL_BGRA"; break;
//		case GL_BGRA_EXT: return @"GL_BGRA_EXT"; break;
//		case GL_BGRA_IMG: return @"GL_BGRA_IMG"; break;
		case GL_BLEND: return @"GL_BLEND"; break;
		case GL_BLEND_COLOR: return @"GL_BLEND_COLOR"; break;
		case GL_BLEND_DST_ALPHA: return @"GL_BLEND_DST_ALPHA"; break;
		case GL_BLEND_DST_RGB: return @"GL_BLEND_DST_RGB"; break;
		case GL_BLEND_EQUATION: return @"GL_BLEND_EQUATION"; break;
//		case GL_BLEND_EQUATION_ALPHA: return @"GL_BLEND_EQUATION_ALPHA"; break;
//		case GL_BLEND_EQUATION_RGB: return @"GL_BLEND_EQUATION_RGB"; break;
		case GL_BLEND_SRC_ALPHA: return @"GL_BLEND_SRC_ALPHA"; break;
		case GL_BLEND_SRC_RGB: return @"GL_BLEND_SRC_RGB"; break;
		case GL_BLUE_BITS: return @"GL_BLUE_BITS"; break;
		case GL_BOOL: return @"GL_BOOL"; break;
		case GL_BOOL_VEC2: return @"GL_BOOL_VEC2"; break;
		case GL_BOOL_VEC3: return @"GL_BOOL_VEC3"; break;
		case GL_BOOL_VEC4: return @"GL_BOOL_VEC4"; break;
			
		case GL_COLOR_CLEAR_VALUE: return @"GL_COLOR_CLEAR_VALUE"; break;
		case GL_COLOR_WRITEMASK: return @"GL_COLOR_WRITEMASK"; break;
		case GL_COMPRESSED_TEXTURE_FORMATS: return @"GL_COMPRESSED_TEXTURE_FORMATS"; break;
		case GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG: return @"GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG"; break;
		case GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG: return @"GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG"; break;
		case GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG: return @"GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG"; break;
		case GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG: return @"GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG"; break;
		case GL_CULL_FACE_MODE: return @"GL_CULL_FACE_MODE"; break;
		case GL_DEPTH_BITS: return @"GL_DEPTH_BITS"; break;
		case GL_DEPTH_CLEAR_VALUE: return @"GL_DEPTH_CLEAR_VALUE"; break;
		case GL_DEPTH_RANGE: return @"GL_DEPTH_RANGE"; break;
		case GL_DEPTH_WRITEMASK: return @"GL_DEPTH_WRITEMASK"; break;
		case GL_EXTENSIONS: return @"GL_EXTENSIONS"; break;
		case GL_FLOAT: return @"GL_FLOAT"; break;
		case GL_FLOAT_VEC2: return @"GL_FLOAT_VEC2"; break;
		case GL_FLOAT_VEC3: return @"GL_FLOAT_VEC3"; break;
		case GL_FLOAT_VEC4: return @"GL_FLOAT_VEC4"; break;
		case GL_FLOAT_MAT2: return @"GL_FLOAT_MAT2"; break;
		case GL_FLOAT_MAT3: return @"GL_FLOAT_MAT3"; break;
		case GL_FLOAT_MAT4: return @"GL_FLOAT_MAT4"; break;
		case GL_FRONT_FACE: return @"GL_FRONT_FACE"; break;
		case GL_GREEN_BITS: return @"GL_GREEN_BITS"; break;
		case GL_IMPLEMENTATION_COLOR_READ_FORMAT: return @"GL_IMPLEMENTATION_COLOR_READ_FORMAT"; break;
		case GL_IMPLEMENTATION_COLOR_READ_TYPE: return @"GL_IMPLEMENTATION_COLOR_READ_TYPE"; break;
		case GL_INT: return @"GL_INT"; break;
		case GL_INT_VEC2: return @"GL_INT_VEC2"; break;
		case GL_INT_VEC3: return @"GL_INT_VEC3"; break;
		case GL_INT_VEC4: return @"GL_INT_VEC4"; break;
		case GL_LINE_WIDTH: return @"GL_LINE_WIDTH"; break;
		case GL_MAX_CUBE_MAP_TEXTURE_SIZE: return @"GL_MAX_CUBE_MAP_TEXTURE_SIZE"; break;
		case GL_MAX_TEXTURE_SIZE: return @"GL_MAX_TEXTURE_SIZE"; break;
		case GL_MAX_VIEWPORT_DIMS: return @"GL_MAX_VIEWPORT_DIMS"; break;
		case GL_NUM_COMPRESSED_TEXTURE_FORMATS: return @"GL_NUM_COMPRESSED_TEXTURE_FORMATS"; break;
		case GL_POLYGON_OFFSET_FACTOR: return @"GL_POLYGON_OFFSET_FACTOR"; break;
		case GL_POLYGON_OFFSET_UNITS: return @"GL_POLYGON_OFFSET_UNITS"; break;
		case GL_RED_BITS: return @"GL_RED_BITS"; break;
		case GL_RENDERER: return @"GL_RENDERER"; break;
		case GL_RGB: return @"GL_RGB"; break;
		case GL_RGBA: return @"GL_RGBA"; break;
		case GL_SAMPLE_COVERAGE_INVERT: return @"GL_SAMPLE_COVERAGE_INVERT"; break;
		case GL_SAMPLE_COVERAGE_VALUE: return @"GL_SAMPLE_COVERAGE_VALUE"; break;
		case GL_SAMPLER_2D: return @"GL_SAMPLER_2D"; break;
		case GL_SAMPLER_CUBE: return @"GL_SAMPLER_CUBE"; break;
		case GL_SHADING_LANGUAGE_VERSION: return @"GL_SHADING_LANGUAGE_VERSION"; break;
		case GL_STENCIL_BACK_WRITEMASK: return @"GL_STENCIL_BACK_WRITEMASK"; break;
		case GL_STENCIL_BITS: return @"GL_STENCIL_BITS"; break;
		case GL_STENCIL_CLEAR_VALUE: return @"GL_STENCIL_CLEAR_VALUE"; break;
		case GL_STENCIL_WRITEMASK: return @"GL_STENCIL_WRITEMASK"; break;
		case GL_SUBPIXEL_BITS: return @"GL_SUBPIXEL_BITS"; break;
		case GL_UNSIGNED_BYTE: return @"GL_UNSIGNED_BYTE"; break;
		case GL_UNSIGNED_SHORT_5_6_5: return @"GL_UNSIGNED_SHORT_5_6_5"; break;
		case GL_UNSIGNED_SHORT_4_4_4_4: return @"GL_UNSIGNED_SHORT_4_4_4_4"; break;
		case GL_UNSIGNED_SHORT_5_5_5_1: return @"GL_UNSIGNED_SHORT_5_5_5_1"; break;
		case GL_VENDOR: return @"GL_VENDOR"; break;
		case GL_VERSION: return @"GL_VERSION"; break;
		case GL_VIEWPORT: return @"GL_VIEWPORT"; break;
		
		// type
			
			
		// format

						
		default:
			NSString* tempString = [NSString stringWithFormat:@"%d", thisEnum];
			FC_WARNING1(@"unknown GLenum", tempString);
			break;
	}
	return nil;
}

#pragma mark - Caps

GLint FCGLCapsMaxTextureSize( void )
{
	GLint maxSize;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxSize);
	return maxSize;
}

void FCGLLogState( void )
{
	NSString* entry;
	entry = [NSString stringWithFormat:@"%d", FCGLCapsMaxTextureSize()];
	FC_LOG1(@"Max Texture Size:%@", entry );
}

#endif // TARGET_OS_IPHONE
