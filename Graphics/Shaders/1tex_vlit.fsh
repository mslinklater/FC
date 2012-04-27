varying lowp vec4 destinationcolor;
varying lowp vec2 texCoord;
uniform sampler2D texture;

void main(void)
{
	gl_FragColor = destinationcolor * texture2D(texture, texCoord);
//	gl_FragColor = texture2D(texture, texCoord);
}
