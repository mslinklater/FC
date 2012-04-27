precision mediump float;

uniform vec4 light_color;
uniform vec3 light_direction;
uniform vec4 ambient_color;

varying mediump vec3 out_normal;
varying mediump vec4 out_diffuse_color;
varying mediump vec4 out_specular_color;

void main(void)
{
	mediump vec4 outcolor = vec4(0.0, 0.0, 0.0, 1.0);
	mediump vec3 norm = normalize( out_normal.xyz );
	mediump vec4 realSpecularColor = out_specular_color;
	realSpecularColor.a = 1.0;
	
	mediump float specularHardness = out_specular_color.a * 255.0;

	mediump vec3 halfplane = normalize(light_direction + vec3( 0.0, 0.0, 1.0 ));

	
	float ndotl = max( 0.0, dot( light_direction, norm ) );
	float ndoth = max( 0.0, dot( halfplane, norm ) );

	outcolor += ambient_color * out_diffuse_color;

	outcolor += ndotl * light_color * out_diffuse_color;

	if( ndoth > 0.0 )
	{
		float power;
		power = pow( ndoth, specularHardness );
		outcolor += power * light_color * realSpecularColor;
	}

	gl_FragColor = outcolor;
}
