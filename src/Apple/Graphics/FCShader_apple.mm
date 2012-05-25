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

#if 1

#import "FCShader_apple.h"
#import "FCCore.h"
#import "FCGL_apple.h"

@implementation FCShader_apple
@synthesize glHandle = _glHandle;

-(id)initType:(eFCShaderType)type withSource:(NSString *)source
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

		_glHandle = FCglCreateShader( glShaderType );
		if (self.glHandle == 0) {
			FC_FATAL( std::string("glCreateShader failed ") + [source UTF8String]);
		}
		
		FCglShaderSource(self.glHandle, 1, &shaderStr, NULL);
		FCglCompileShader(self.glHandle);
		
		GLint status;
		FCglGetShaderiv(self.glHandle, GL_COMPILE_STATUS, &status);
		
		if (!status) {
			GLint infoLen;
			FCglGetShaderiv(self.glHandle, GL_INFO_LOG_LENGTH, &infoLen);
			if (infoLen > 1) {
				char* infoLog = (char*)malloc(sizeof(char) * infoLen);
				FCglGetShaderInfoLog(self.glHandle, infoLen, NULL, infoLog);
				NSString* errorString = [NSString stringWithFormat:@"%s", infoLog];
				FC_FATAL([errorString UTF8String]);
				free(infoLog);
			}
			FCglDeleteShader(self.glHandle);
		}		
	}
	return self;
}

-(void)dealloc
{
	FCglDeleteShader(self.glHandle);
}

@end

#endif // defined(FC_GRAPHICS)

