attribute vec4 position;
uniform vec4 diffuse_color;
uniform mat4 projection;
uniform mat4 modelview;

varying vec4 destinationcolor;

void main( void )
{
	destinationcolor = diffuse_color;
	gl_Position = projection * modelview * position;
}
