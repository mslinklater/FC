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
#ifndef FCGLAPI_h
#define FCGLAPI_h

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

class FCGLAPI {
public:
	FCGLAPI();
	virtual ~FCGLAPI();

	void ActivateTexture( GLenum texture );
	void AttachShader( GLuint program, GLuint shader );
	void BindBuffer( GLenum target, GLuint buffer );
	void BindFrameBuffer( GLenum target, GLuint framebuffer );
	void BindRenderBuffer( GLenum target, GLuint renderBuffer );
	void BindTexture( GLenum target, GLuint texture );
	void BufferData( GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage );
	GLenum CheckFrameBufferStatus( GLenum target );
	void Clear( GLbitfield mask );
	void ClearColor( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha );
	void CompileShader( GLuint shader );
	GLuint CreateProgram();
	GLuint CreateShader();
	void DeleteBuffers( GLsizei n, const GLuint* buffers );
	void DeleteFramebuffers( GLsizei n, const GLuint* framebuffers );
	void DeleteProgram( GLuint program );
	void DeleteRenderBuffers( GLsizei n, const GLuint* framebuffers );
	void DeleteShader( GLuint shader );
	void DeleteTextures( GLsizei n, const GLuint* textures );
	void Disable( GLenum cap );
	void DrawArrays( GLenum mode, GLint first, GLsizei count );
	void DrawElements( GLenum mode, GLsizei count, GLenum type, const GLvoid* indices );
	void Enable( GLenum cap );
	void EnableVertexAttribArray( GLuint index );
	void FramebufferRenderbuffer( GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer );
	void FramebufferTexture2D( GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level );
	void GenBuffers( GLsizei n, GLuint* buffers );
	void GenerateMipMap( GLenum target );
	void GenFramebuffers( GLsizei n, GLuint* framebuffers );
	void GenRenderbuffers( GLsizei n, GLuint* renderbuffers );
	void GenTextures( GLsizei n, GLuint* textures );
	void GetActiveAttrib( GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum type, GLchar* name );
	void GetActiveUniform( GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum type, GLchar* name );
	int GetAttribLocation( GLuint program, const GLchar* name );
	GLenum GetError( void );
	void GetProgramiv( GLuint program, GLenum pname, GLint* params );
	void GetProgramInfoLog( GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog );
	void GetRenderbufferParameteriv( GLenum target, GLenum pname, GLint* params );
	void GetShaderiv( GLuint shader, GLenum pname, GLint* params );
	void GetShaderInfoLog( GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* infolog );
	int GetUniformLocation( GLuint program, const GLchar* name );
	void LinkProgram( GLuint program );
	
	
private:
};

#endif
#endif
