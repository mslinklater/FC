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

#ifndef FCVector_h
#define FCVector_h

#include "FCUtility.h"

//namespace FC {
	
class FCVector2f {
public:
	FCVector2f(){}
	FCVector2f( float xIn, float yIn ) : x(xIn), y(yIn) {}
	FCVector2f( const FCVector2f& vec ) : x(vec.x), y(vec.y) {}
	
	FCVector2f operator+( const FCVector2f &v ){ return FCVector2f( x + v.x, y + v.y); }
	FCVector2f operator-( const FCVector2f &v ){ return FCVector2f( x - v.x, y - v.y); }
	FCVector2f operator*( float mag ){ return FCVector2f( x * mag, y * mag ); }
	FCVector2f operator/( float mag ){ return FCVector2f( x / mag, y / mag ); }
	
	void operator+=( const FCVector2f& v ){ x += v.x, y += v.y; }
	
	void Zero( void ){ x = y = 0.0f; }
	void RotateDeg( float degrees )
	{  
		float rads = degrees * kFCDegToRad;		
 		float _x = x * cosf(rads) - y * sinf(rads);
		float _y = x * sinf(rads) + y * cosf(rads);
		x = _x;
		y = _y;
	}
	
	float	x;
	float	y;
};

inline float FCMagnitude( const FCVector2f& v )
{
	return (float)sqrt(v.x * v.x + v.y * v.y);
}


inline FCVector2f FCNormalised( const FCVector2f& v )
{
	float mag = FCMagnitude( v );
	return FCVector2f( v.x / mag, v.y / mag );
}
	
inline float FCDistanceSquared( FCVector2f& v1, FCVector2f& v2 ) 
{
	float xDiff = v1.x - v2.x;
	float yDiff = v1.y - v2.y;
	return xDiff * xDiff + yDiff * yDiff;
}

inline float FCDistance( FCVector2f& v1, FCVector2f& v2 ) 
{
	float xDiff = v1.x - v2.x;
	float yDiff = v1.y - v2.y;
	return (float)sqrt( xDiff * xDiff + yDiff * yDiff );
}

class FCVector3f {
public:
	FCVector3f(){}
	FCVector3f( float xIn, float yIn, float zIn ) : x(xIn), y(yIn), z(zIn) {}
	FCVector3f( const FCVector3f& vec ) : x(vec.x), y(vec.y), z(vec.z) {}

	FCVector3f operator+( FCVector3f &v ){ return FCVector3f( x + v.x, y + v.y, z + v.z); }
	FCVector3f operator-( FCVector3f &v ){ return FCVector3f( x - v.x, y - v.y, z - v.z); }

	// Cross product
	FCVector3f operator*( FCVector3f &v ){
		return FCVector3f( (y * v.z - z * v.y), (z * v.x - x * v.z), (x * v.y - y * v.x) );
	}
	
	FCVector3f operator*( float f ){ return FCVector3f( x * f, y * f, z * f ); }

	void Zero( void ){ x = y = z = 0.0f; }
	void BlenderToEngine( void ){ z = -z; }	// from blender coordinates to FC engine
	void Normalize( void ){
		float mag = sqrt( x * x + y * y + z * z );
		x /= mag;
		y /= mag;
		z /= mag;
	}
	
	float	x;
	float	y;
	float	z;
};

inline float FCMagnitude( const FCVector3f& v )
{
	return (float)sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

class FCVector4f {
public:
	FCVector4f(){}
	FCVector4f( float xIn, float yIn, float zIn, float wIn ) : x(xIn), y(yIn), z(zIn), w(wIn) {}
	FCVector4f( const FCVector4f& vec ) : x(vec.x), y(vec.y), z(vec.z), w(vec.w) {}

	FCVector4f operator+( FCVector4f &v ){ return FCVector4f( x + v.x, y + v.y, z + v.z, w + v.w); }
	FCVector4f operator-( FCVector4f &v ){ return FCVector4f( x - v.x, y - v.y, z - v.z, w - v.w); }

	void Zero( void ){ x = y = z = w = 0.0f; }

	float	x;
	float	y;
	float	z;
	float	w;
};
	
class FCVector2i {
public:
	FCVector2i(){}
	FCVector2i( int xIn, int yIn ) : x(xIn), y(yIn) {}
	FCVector2i( const FCVector2i& vec ) : x(vec.x), y(vec.y) {}
	
	FCVector2i operator+( FCVector2i &v ){ return FCVector2i( x + v.x, y + v.y); }
	FCVector2i operator-( FCVector2i &v ){ return FCVector2i( x - v.x, y - v.y); }
	
	void Zero( void ){ x = y = 0; }
	
	int	x;
	int	y;
};

class FCVector2us {
public:
	FCVector2us(){}
	FCVector2us( unsigned short xIn, unsigned short yIn ) : x(xIn), y(yIn) {}
	FCVector2us( const FCVector2us& vec ) : x(vec.x), y(vec.y) {}
	
	FCVector2us operator+( FCVector2us &v ){ return FCVector2us( x + v.x, y + v.y); }
	FCVector2us operator-( FCVector2us &v ){ return FCVector2us( x - v.x, y - v.y); }
	
	void Zero( void ){ x = y = 0; }
	
	unsigned short	x;
	unsigned short	y;
};

class FCVector3s {
	public:
		FCVector3s(){}
		FCVector3s( short xIn, short yIn, short zIn ) : x(xIn), y(yIn), z(zIn) {}
		FCVector3s( const FCVector3s& vec ) : x(vec.x), y(vec.y), z(vec.z) {}
		
		FCVector3s operator+( FCVector3s &v ){ return FCVector3s( x + v.x, y + v.y, z + v.z); }
		FCVector3s operator-( FCVector3s &v ){ return FCVector3s( x - v.x, y - v.y, z - v.z); }
		
		void Zero( void ){ x = y = z = 0; }
		
		short	x;
		short	y;
		short	z;
};

class FCVector3us {
	public:
		FCVector3us(){}
		FCVector3us( unsigned short xIn, unsigned short yIn, unsigned short zIn ) : x(xIn), y(yIn), z(zIn) {}
		FCVector3us( const FCVector3us& vec ) : x(vec.x), y(vec.y), z(vec.z) {}
		
		FCVector3us operator+( FCVector3us &v ){ return FCVector3us( x + v.x, y + v.y, z + v.z); }
		FCVector3us operator-( FCVector3us &v ){ return FCVector3us( x - v.x, y - v.y, z - v.z); }
		
		void Zero( void ){ x = y = z = 0; }
		
		unsigned short	x;
		unsigned short	y;
		unsigned short	z;
};

class FCVector4uc {
public:
	FCVector4uc(){}
	FCVector4uc( unsigned char xIn, unsigned char yIn, unsigned char zIn, unsigned char wIn ) : x(xIn), y(yIn), z(zIn), w(wIn) {}		
	FCVector4uc( const FCVector4uc& vec ) : x(vec.x), y(vec.y), z(vec.z), w(vec.w) {}

	FCVector4uc operator+( FCVector4uc &v ){ return FCVector4uc( x + v.x, y + v.y, z + v.z, w + v.w ); }
	FCVector4uc operator-( FCVector4uc &v ){ return FCVector4uc( x - v.x, y - v.y, z - v.z, w - v.w ); }
	
	void Zero( void ){ x = y = z = w = 0; }

	unsigned char x;
	unsigned char y;
	unsigned char z;
	unsigned char w;
};

//}

#endif // FCVector_h
