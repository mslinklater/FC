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

#import "FCShader.h"
#import "FCCore.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>

@implementation FCShader
@synthesize glHandle = _glHandle;

-(id)initType:(eShaderType)type withSource:(NSString *)source
{
	self = [super init];
	if (self) {
		const char* shaderStr = [source UTF8String];
		GLenum glShaderType;
		
		switch (type) 
		{
			case kShaderTypeFragment:
				glShaderType = GL_FRAGMENT_SHADER;
				break;
			case kShaderTypeVertex:
				glShaderType = GL_VERTEX_SHADER;
				break;				
			default:
				break;
		}

		_glHandle = glCreateShader( glShaderType );
		if (self.glHandle == 0) {
			FC_FATAL1(@"glCreateShader failed", source);
		}
		
		glShaderSource(self.glHandle, 1, &shaderStr, NULL);
		glCompileShader(self.glHandle);
		
		GLint status;
		glGetShaderiv(self.glHandle, GL_COMPILE_STATUS, &status);
		
		if (!status) {
			GLint infoLen;
			glGetShaderiv(self.glHandle, GL_INFO_LOG_LENGTH, &infoLen);
			if (infoLen > 1) {
				char* infoLog = (char*)malloc(sizeof(char) * infoLen);
				glGetShaderInfoLog(self.glHandle, infoLen, NULL, infoLog);
				NSString* errorString = [NSString stringWithFormat:@"%s", infoLog];
				FC_ERROR(errorString);
				free(infoLog);
			}
			glDeleteShader(self.glHandle);
		}		
	}
	return self;
}

-(void)dealloc
{
	glDeleteShader(self.glHandle);
	[super dealloc];
}

@end

#endif // TARGET_OS_IPHONE

