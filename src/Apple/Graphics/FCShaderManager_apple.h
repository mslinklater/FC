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

#import <Foundation/Foundation.h>
#import "FCShaderProgram_apple.h"
#import "FCShaderUniform_apple.h"

@interface FCShaderManager_apple : NSObject {
	NSMutableDictionary* _shaders;
	NSMutableDictionary* _programs;
}
@property(nonatomic, strong) NSMutableDictionary* shaders;
@property(nonatomic, strong) NSMutableDictionary* programs;

+(FCShaderManager_apple*)instance;

//-(FCShader*)addShader:(NSString*)name;
//-(FCShader*)shader:(NSString*)name;

//-(FCShaderProgram*)addProgram:(NSString*)name as:(NSString*)shaderName;

-(FCShaderProgram_apple*)program:(NSString*)name;
-(NSArray*)allShaders;

-(void)activateShader:(NSString*)shader;
@end

#endif // defined(FC_GRAPHICS)

