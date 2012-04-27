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

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>
#import "FCGLHelpers.h"
#import "FCCore.h"

extern GLuint FCGL_currentProgram;

inline static void FCglActiveTexture( GLenum texture )
{
	glActiveTexture( texture );
	GLCHECK;
}

inline static void FCglAttachShader(GLuint program, GLuint shader)
{
	glAttachShader(program, shader);
	GLCHECK;
}

inline static void FCglBindBuffer( GLenum target, GLuint buffer )
{
	glBindBuffer(target, buffer);
	GLCHECK;
}

inline static void FCglBindFramebuffer(GLenum target, GLuint framebuffer )
{
	glBindFramebuffer(target, framebuffer);
	GLCHECK;
}

inline static void FCglBindRenderbuffer( GLenum target, GLuint renderbuffer )
{
	glBindRenderbuffer(target, renderbuffer);
	GLCHECK;
}

inline static void FCglBindTexture( GLenum target, GLuint texture )
{
	glBindTexture(target, texture);
	GLCHECK;
}

inline static void FCglBufferData( GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage )
{
	glBufferData(target, size, data, usage);
	GLCHECK;
}

inline static GLenum FCglCheckFramebufferStatus( GLenum target )
{
	GLenum ret = glCheckFramebufferStatus(target);
	GLCHECK;
	return ret;
}

inline static void FCglClear(GLbitfield mask)
{
	glClear(mask);
	GLCHECK;
}

inline static void FCglClearColor( GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha )
{
	glClearColor(red, green, blue, alpha);
	GLCHECK;
}

inline static void FCglCompileShader( GLuint shader )
{
	glCompileShader(shader);
	GLCHECK;
}

inline static GLuint FCglCreateProgram()
{
	GLuint ret = glCreateProgram();
	GLCHECK;
	return ret;
}

inline static GLuint FCglCreateShader( GLenum type )
{
	GLuint ret = glCreateShader(type);
	GLCHECK;
	return ret;
}

inline static void FCglDeleteBuffers( GLsizei n, const GLuint* buffers )
{
	glDeleteBuffers(n, buffers);
	GLCHECK;
}

inline static void FCglDeleteFramebuffers( GLsizei n, const GLuint* framebuffers )
{
	glDeleteFramebuffers(n, framebuffers);
	GLCHECK;
}

inline static void FCglDeleteProgram( GLuint program )
{
	glDeleteProgram(program);
	GLCHECK;
}

inline static void FCglDeleteRenderbuffers( GLsizei n, const GLuint* framebuffers )
{
	glDeleteRenderbuffers(n, framebuffers);
	GLCHECK;
}

inline static void FCglDeleteShader( GLuint shader )
{
	glDeleteShader(shader);
	GLCHECK;
}

inline static void FCglDeleteTextures( GLsizei n, const GLuint* textures )
{
	glDeleteTextures(n, textures);
	GLCHECK;
}

inline static void FCglDisable( GLenum cap )
{
	glDisable(cap);
	GLCHECK;
}

inline static void FCglDrawArrays(GLenum mode, GLint first, GLsizei count)
{
	glDrawArrays(mode, first, count);
	GLCHECK;
}

inline static void FCglDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid* indices)
{
	glDrawElements(mode, count, type, indices);
	GLCHECK;
}

inline static void FCglEnable( GLenum cap )
{
	glEnable(cap);
	GLCHECK;
}

inline static void FCglEnableVertexAttribArray( GLuint index )
{
	glEnableVertexAttribArray(index);
	GLCHECK;
}

inline static void FCglFramebufferRenderbuffer( GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer )
{
	glFramebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
	GLCHECK;
}

inline static void FCglFramebufferTexture2D( GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level )
{
	glFramebufferTexture2D(target, attachment, textarget, texture, level);
	GLCHECK;
}

inline static void FCglGenBuffers( GLsizei n, GLuint* buffers )
{
	glGenBuffers(n, buffers);
	GLCHECK;
}

inline static void FCglGenerateMipmap( GLenum target )
{
	glGenerateMipmap(target);
	GLCHECK;
}

inline static void FCglGenFramebuffers( GLsizei n, GLuint* framebuffers )
{
	glGenFramebuffers(n, framebuffers);
	GLCHECK;
}


inline static void FCglGenRenderbuffers( GLsizei n, GLuint* renderbuffers )
{
	glGenRenderbuffers(n, renderbuffers);
	GLCHECK;
}

inline static void FCglGenTextures( GLsizei n, GLuint* textures )
{
	glGenTextures(n, textures);
	GLCHECK;
}

inline static void FCglGetActiveAttrib(GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name)
{
	glGetActiveAttrib(program, index, bufsize, length, size, type, name);
	GLCHECK;
}

inline static void FCglGetActiveUniform(GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name )
{
	glGetActiveUniform(program, index, bufsize, length, size, type, name);
	GLCHECK;
}

inline static int FCglGetAttribLocation(GLuint program, const GLchar* name)
{
	int ret = glGetAttribLocation(program, name);
	GLCHECK;
	return ret;
}

inline static GLenum FCglGetError( void )
{
	return glGetError();
}

inline static void FCglGetProgramiv( GLuint program, GLenum pname, GLint* params)
{
	glGetProgramiv(program, pname, params);
	GLCHECK;
}

inline static void FCglGetProgramInfoLog(GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog)
{
	glGetProgramInfoLog(program, bufsize, length, infolog);
	GLCHECK;
}

inline static void FCglGetRenderbufferParameteriv(GLenum target, GLenum pname, GLint* params)
{
	glGetRenderbufferParameteriv(target, pname, params);
	GLCHECK;
}

inline static void FCglGetShaderiv( GLuint shader, GLenum pname, GLint* params )
{
	glGetShaderiv(shader, pname, params);
	GLCHECK;
}

inline static void FCglGetShaderInfoLog(GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* infolog)
{
	glGetShaderInfoLog(shader, bufsize, length, infolog);
	GLCHECK;
}

inline static int FCglGetUniformLocation(GLuint program, const GLchar* name)
{
	int ret = glGetUniformLocation(program, name);
	GLCHECK;
	return ret;
}

inline static void FCglLinkProgram(GLuint program)
{
	glLinkProgram(program);
	GLCHECK;
}

inline static void FCglPixelStorei( GLenum pname, GLint param )
{
	glPixelStorei(pname, param);
	GLCHECK;
}

inline static void FCglRenderbufferStorage(GLenum target, GLenum internalformat, GLsizei width, GLsizei height)
{
	glRenderbufferStorage(target, internalformat, width, height);
	GLCHECK;
}

inline static void FCglShaderSource( GLuint shader, GLsizei count, const GLchar** string, const GLint* length )
{
	glShaderSource(shader, count, string, length);
	GLCHECK;
}

inline static void FCglTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels)
{
	glTexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
	GLCHECK;
}

inline static void FCglTexParameteri( GLenum target, GLenum pname, GLint param )
{
	glTexParameteri(target, pname, param);
	GLCHECK;
}

inline static void FCglUniform1f( GLint location, GLfloat v0 )
{
	glUniform1f(location, v0);
	GLCHECK;		
}

inline static void FCglUniform1i( GLint location, GLint v0 )
{
	glUniform1i(location, v0);
	GLCHECK;		
}

inline static void FCglUniform1fv( GLint location, GLsizei count, const GLfloat* value)
{
	glUniform1fv(location, count, value);
	GLCHECK;		
}

inline static void FCglUniform1iv( GLint location, GLsizei count, const GLint* value)
{
	glUniform1iv(location, count, value);
	GLCHECK;		
}

inline static void FCglUniform2fv( GLint location, GLsizei count, const GLfloat* value)
{
	glUniform2fv(location, count, value);
	GLCHECK;		
}

inline static void FCglUniform2iv( GLint location, GLsizei count, const GLint* value)
{
	glUniform2iv(location, count, value);
	GLCHECK;		
}

inline static void FCglUniform3fv( GLint location, GLsizei count, const GLfloat* value)
{
	glUniform3fv(location, count, value);
	GLCHECK;
}

inline static void FCglUniform3iv( GLint location, GLsizei count, const GLint* value)
{
	glUniform3iv(location, count, value);
	GLCHECK;
}

inline static void FCglUniform4fv( GLint location, GLsizei count, const GLfloat* value)
{
	glUniform4fv(location, count, value);
	GLCHECK;
}

inline static void FCglUniform4iv( GLint location, GLsizei count, const GLint* value)
{
	glUniform4iv(location, count, value);
	GLCHECK;
}

inline static void FCglUniformMatrix2fv( GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
	glUniformMatrix2fv(location, count, transpose, value);
	GLCHECK;
}

inline static void FCglUniformMatrix3fv( GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
	glUniformMatrix3fv(location, count, transpose, value);
	GLCHECK;
}

inline static void FCglUniformMatrix4fv( GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
	glUniformMatrix4fv(location, count, transpose, value);
	GLCHECK;
}

inline static void FCglUseProgram( GLuint program )
{
	if (FCGL_currentProgram != program) {
		glUseProgram(program);
		GLCHECK;
		FCGL_currentProgram = program;
	}
}

inline static void FCglValidateProgram( GLuint program )
{
	glValidateProgram(program);
	GLCHECK;
}

inline static void FCglVertexAttribPointer( GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
{
	glVertexAttribPointer(indx, size, type, normalized, stride, ptr);
	GLCHECK;
}

inline static void FCglViewport(GLint x, GLint y, GLsizei width, GLsizei height)
{
	glViewport(x, y, width, height);
	GLCHECK;
}






