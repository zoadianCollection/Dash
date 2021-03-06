module math.quaternion;
import core.properties;
import math.matrix, math.vector;

import std.signals, std.conv;
import std.math;

final class Quaternion
{
public:
	this()
	{
		_w = 1.0f;
		_x = 0.0f;
		_y = 0.0f;
		_z = 0.0f;

		matrix = new Matrix!4();
	}

	this( const float x, const float y, const float z, const float angle )
	{
		immutable float fHalfAngle = angle / 2.0f;
		immutable float fSin = sin( fHalfAngle );

		_w = cos( fHalfAngle );
		_x = fSin * x;
		_y = fSin * y;
		_z = fSin * z;

		matrix = new Matrix!4();
	}

	static Quaternion fromEulerAngles( Vector!3 angles )
	{
		return fromEulerAngles( angles.x, angles.y, angles.z );
	}
	
	static Quaternion fromEulerAngles( const float x, const float y, const float z )
	{
		auto res = new Quaternion;

		float cosHalfX = cos( x / 2 );
		float cosHalfY = cos( y / 2 );
		float cosHalfZ = cos( z / 2 );
		float sinHalfX = sin( x / 2 );
		float sinHalfY = sin( y / 2 );
		float sinHalfZ = sin( z / 2 );
		
		// From here: http://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles#Conversion
		res._x = ( cosHalfZ * cosHalfY * cosHalfX ) + ( sinHalfZ * sinHalfY * sinHalfX );
		res._y = ( sinHalfZ * cosHalfY * cosHalfX ) - ( cosHalfZ * sinHalfY * sinHalfX );
		res._z = ( cosHalfZ * sinHalfY * cosHalfX ) + ( sinHalfZ * cosHalfY * sinHalfX );
		res._w = ( cosHalfZ * cosHalfY * sinHalfX ) - ( sinHalfZ * sinHalfX * cosHalfX );

		return res;
	}

	mixin Signal!( string, string );

	mixin EmmittingPropertySetDirty!( "float", "x", "matrix", "public" );
	mixin EmmittingPropertySetDirty!( "float", "y", "matrix", "public" );
	mixin EmmittingPropertySetDirty!( "float", "z", "matrix", "public" );
	mixin EmmittingPropertySetDirty!( "float", "w", "matrix", "public" );

	mixin DirtyProperty!( "Matrix!4", "matrix", "updateMatrix" );

	final Quaternion opBinary( string op )( Quaternion other )
	{
		static if ( op  == "*" )
		{
			return new Quaternion(
				x * other.w + y * other.z - z * other.y + w * other.x,
				-x * other.z + y * other.w + z * other.x + w * other.y,
				x * other.y - y * other.x + z * other.w + w * other.z,
				-x * other.x - y * other.y - z * other.z + w * other.w );
		}
		else static assert ( 0, "Operator " ~ op ~ " not implemented." );
	}

	final ref Quaternion opOpAssign( string op )( Quaternion other )
	{
		static if ( op == "*" )
		{
			x = x * other.w + y * other.z - z * other.y + w * other.x;
			y = -x * other.z + y * other.w + z * other.x + w * other.y;
			z = x * other.y - y * other.x + z * other.w + w * other.z;
			w = -x * other.x - y * other.y - z * other.z + w * other.w;

			return this;
		}
		else static assert ( 0, "Operator " ~ op ~ " not implemented for assign." );
	}

private:
	final void updateMatrix()
	{
		_matrix.matrix[ 0 ][ 0 ] = 1.0f - 2.0f * y * y - 2.0f * z * z;
		_matrix.matrix[ 0 ][ 1 ] = 2.0f * x * y - 2.0f * z * w;
		_matrix.matrix[ 0 ][ 2 ] = 2.0f * x * z + 2.0f * y * w;
		_matrix.matrix[ 1 ][ 0 ] = 2.0f * x * y + 2.0f * z * w;
		_matrix.matrix[ 1 ][ 1 ] = 1.0f - 2.0f * x * x - 2.0f * z * z;
		_matrix.matrix[ 1 ][ 2 ] = 2.0f * y * z - 2.0f * x * w;
		_matrix.matrix[ 2 ][ 0 ] = 2.0f * x * z - 2.0f * y * w;
		_matrix.matrix[ 2 ][ 1 ] = 2.0f * y * z + 2.0f * x * w;
		_matrix.matrix[ 2 ][ 2 ] = 1.0f - 2.0f * x * x - 2.0f * y * y;
	}
}
