attribute vec4 position;
attribute vec4 diffusecolor;
uniform mat4 projection;
uniform mat4 modelview;

varying vec4 destinationcolor;

void main( void )
{
	destinationcolor = diffusecolor;
	gl_Position = projection * modelview * position;
}
