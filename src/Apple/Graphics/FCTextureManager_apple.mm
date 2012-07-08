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
#if 0
#if defined (FC_GRAPHICS)

#import "FCTextureManager_apple.h"
#import "FCCore.h"

#include "GLES/FCGL.h"

IFCTextureManager* plt_FCTextureManager_Instance()
{
	static FCTextureManagerProxy* pInstance = 0;
	if (!pInstance) {
		pInstance = new FCTextureManagerProxy;
	}
	return pInstance;
}

@implementation FCTextureManager_apple

@synthesize debugTexture = _debugTexture;

+(FCTextureManager_apple*)instance;
{
	static FCTextureManager_apple* pInstance = 0;
	if( !pInstance )
	{
		pInstance = [[FCTextureManager_apple alloc] init];
	}
	return pInstance;
}

-(id)init
{
	self = [super init];
	if (self) {
		// create the debug texture

		FCglPixelStorei(GL_UNPACK_ALIGNMENT, 1);
		
		FCglGenTextures(1, &_debugTexture);
		FCglBindTexture(GL_TEXTURE_2D, _debugTexture);
		
		const unsigned int kDebugTexRes = 16;
		GLubyte* pixels = new GLubyte[ kDebugTexRes * kDebugTexRes * 4 ];

		GLubyte* pFill = pixels;
		for (uint32_t row = 0; row < kDebugTexRes; row++) {
			for (uint32_t col = 0; col < kDebugTexRes; col++) {
				if ((row + col) & 1) {
					*pFill = 255; pFill++;
					*pFill = 255; pFill++;
					*pFill = 255; pFill++;
					*pFill = 255; pFill++;
				} else {
					*pFill = 0; pFill++;
					*pFill = 0; pFill++;
					*pFill = 0; pFill++;
					*pFill = 255; pFill++;					
				}
			}
		}

		FCglTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, kDebugTexRes, kDebugTexRes, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
		FCglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		FCglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

		FCglGenerateMipmap( GL_TEXTURE_2D );

		delete [] pixels;
		pixels = 0;
		
	}
	return self;
}

-(void)dealloc
{
	FCglDeleteTextures(1, &_debugTexture);
}

-(void)bindDebugTextureTo:(GLuint)attributeHandle
{
	FCglActiveTexture(GL_TEXTURE0);
	FCglBindTexture(GL_TEXTURE_2D, _debugTexture);
	FCglUniform1i(attributeHandle, 0);
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
}


@end

#endif // defined(FC_GRAPHICS)
#endif

