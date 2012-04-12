attribute vec4 position;
attribute vec4 diffusecolor;
attribute vec3 normal;

uniform vec4 light_color;
uniform vec3 light_direction;
uniform vec4 ambient_color;
uniform mat4 projection;
uniform mat4 modelview;

varying vec4 destinationcolor;

void main( void )
{	
	vec4 calculated_color = vec4( 0.0, 0.0, 0.0, 1.0 );
	vec3 halfplane = normalize(light_direction + vec3( 0.0, 0.0, 1.0 ));
	
	vec4 specular_color = vec4( 1.0, 1.0, 1.0, 1.0 );
	
	float ndotl;
	float ndoth;
	
	ndotl = max( 0.0, dot( normal, light_direction ) );
	ndoth = max( 0.0, dot( normal, halfplane ) );
	
	calculated_color += ndotl * light_color * diffusecolor;
	calculated_color += ambient_color * diffusecolor;
	
	if( ndoth > 0.0 )
	{
		float power;
		power = pow( ndoth, 8.0 );
		calculated_color += power * light_color * specular_color;
	}
	
	destinationcolor = calculated_color;
	
	gl_Position = projection * modelview * position;
}
