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

#import "FCUtility.h"

namespace FC {
	
class Vector2f {
public:
	Vector2f(){}
	Vector2f( float xIn, float yIn ) : x(xIn), y(yIn) {}
	Vector2f( const Vector2f& vec ) : x(vec.x), y(vec.y) {}
	
	Vector2f operator+( const Vector2f &v ){ return Vector2f( x + v.x, y + v.y); }
	Vector2f operator-( const Vector2f &v ){ return Vector2f( x - v.x, y - v.y); }
	Vector2f operator*( float mag ){ return Vector2f( x * mag, y * mag ); }
	Vector2f operator/( float mag ){ return Vector2f( x / mag, y / mag ); }
	
	void operator+=( const Vector2f& v ){ x += v.x, y += v.y; }
	
	void Zero( void ){ x = y = 0.0f; }
	void RotateDeg( float degrees )
	{  
		float rads = degrees * kDegToRad;		
		float _x = x * cosf(rads) - y * sinf(rads);
		float _y = x * sinf(rads) + y * cosf(rads);
		x = _x;
		y = _y;
	}
	
	float	x;
	float	y;
};

inline float Magnitude( const Vector2f& v )
{
	return (float)sqrt(v.x * v.x + v.y * v.y);
}


inline Vector2f Normalised( const Vector2f& v )
{
	float mag = Magnitude( v );
	return Vector2f( v.x / mag, v.y / mag );
}
	
inline float DistanceSquared( Vector2f& v1, Vector2f& v2 ) 
{
	float xDiff = v1.x - v2.x;
	float yDiff = v1.y - v2.y;
	return xDiff * xDiff + yDiff * yDiff;
}

inline float Distance( Vector2f& v1, Vector2f& v2 ) 
{
	float xDiff = v1.x - v2.x;
	float yDiff = v1.y - v2.y;
	return (float)sqrt( xDiff * xDiff + yDiff * yDiff );
}

class Vector3f {
public:
	Vector3f(){}
	Vector3f( float xIn, float yIn, float zIn ) : x(xIn), y(yIn), z(zIn) {}
	Vector3f( const Vector3f& vec ) : x(vec.x), y(vec.y), z(vec.z) {}

	Vector3f operator+( Vector3f &v ){ return Vector3f( x + v.x, y + v.y, z + v.z); }
	Vector3f operator-( Vector3f &v ){ return Vector3f( x - v.x, y - v.y, z - v.z); }
	
	void Zero( void ){ x = y = z = 0.0f; }
	void BlenderToEngine( void ){ z = -z; }	// from blender coordinates to FC engine
	
	float	x;
	float	y;
	float	z;
};

inline float Magnitude( const Vector3f& v )
{
	return (float)sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

class Vector4f {
public:
	Vector4f(){}
	Vector4f( float xIn, float yIn, float zIn, float wIn ) : x(xIn), y(yIn), z(zIn), w(wIn) {}
	Vector4f( const Vector4f& vec ) : x(vec.x), y(vec.y), z(vec.z), w(vec.w) {}

	Vector4f operator+( Vector4f &v ){ return Vector4f( x + v.x, y + v.y, z + v.z, w + v.w); }
	Vector4f operator-( Vector4f &v ){ return Vector4f( x - v.x, y - v.y, z - v.z, w - v.w); }

	void Zero( void ){ x = y = z = w = 0.0f; }

	float	x;
	float	y;
	float	z;
	float	w;
};
	
class Vector2i {
public:
	Vector2i(){}
	Vector2i( int xIn, int yIn ) : x(xIn), y(yIn) {}
	Vector2i( const Vector2i& vec ) : x(vec.x), y(vec.y) {}
	
	Vector2i operator+( Vector2i &v ){ return Vector2i( x + v.x, y + v.y); }
	Vector2i operator-( Vector2i &v ){ return Vector2i( x - v.x, y - v.y); }
	
	void Zero( void ){ x = y = 0; }
	
	int	x;
	int	y;
};

class Vector2us {
public:
	Vector2us(){}
	Vector2us( unsigned short xIn, unsigned short yIn ) : x(xIn), y(yIn) {}
	Vector2us( const Vector2us& vec ) : x(vec.x), y(vec.y) {}
	
	Vector2us operator+( Vector2us &v ){ return Vector2us( x + v.x, y + v.y); }
	Vector2us operator-( Vector2us &v ){ return Vector2us( x - v.x, y - v.y); }
	
	void Zero( void ){ x = y = 0; }
	
	unsigned short	x;
	unsigned short	y;
};

class Vector3s {
	public:
		Vector3s(){}
		Vector3s( short xIn, short yIn, short zIn ) : x(xIn), y(yIn), z(zIn) {}
		Vector3s( const Vector3s& vec ) : x(vec.x), y(vec.y), z(vec.z) {}
		
		Vector3s operator+( Vector3s &v ){ return Vector3s( x + v.x, y + v.y, z + v.z); }
		Vector3s operator-( Vector3s &v ){ return Vector3s( x - v.x, y - v.y, z - v.z); }
		
		void Zero( void ){ x = y = z = 0; }
		
		short	x;
		short	y;
		short	z;
};

class Vector3us {
	public:
		Vector3us(){}
		Vector3us( unsigned short xIn, unsigned short yIn, unsigned short zIn ) : x(xIn), y(yIn), z(zIn) {}
		Vector3us( const Vector3us& vec ) : x(vec.x), y(vec.y), z(vec.z) {}
		
		Vector3us operator+( Vector3us &v ){ return Vector3us( x + v.x, y + v.y, z + v.z); }
		Vector3us operator-( Vector3us &v ){ return Vector3us( x - v.x, y - v.y, z - v.z); }
		
		void Zero( void ){ x = y = z = 0; }
		
		unsigned short	x;
		unsigned short	y;
		unsigned short	z;
};

class Vector4uc {
public:
	Vector4uc(){}
	Vector4uc( unsigned char xIn, unsigned char yIn, unsigned char zIn, unsigned char wIn ) : x(xIn), y(yIn), z(zIn), w(wIn) {}		
	Vector4uc( const Vector4uc& vec ) : x(vec.x), y(vec.y), z(vec.z), w(vec.w) {}

	Vector4uc operator+( Vector4uc &v ){ return Vector4uc( x + v.x, y + v.y, z + v.z, w + v.w ); }
	Vector4uc operator-( Vector4uc &v ){ return Vector4uc( x - v.x, y - v.y, z - v.z, w - v.w ); }
	
	void Zero( void ){ x = y = z = w = 0; }

	unsigned char x;
	unsigned char y;
	unsigned char z;
	unsigned char w;
};

}

