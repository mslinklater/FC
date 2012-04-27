attribute vec4 position;
attribute vec4 diffuse_color;
attribute vec3 normal;
attribute vec4 specular_color;

uniform mat4 projection;
uniform mat4 modelview;

varying mediump vec3 out_normal;
varying mediump vec4 out_diffuse_color;
varying mediump vec4 out_specular_color;

void main( void )
{	
	gl_Position = projection * modelview * position;
	
	out_normal = normal;
	out_diffuse_color = diffuse_color;
	out_specular_color = specular_color;
}
