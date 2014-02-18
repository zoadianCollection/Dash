module math.transform;
import core.properties, core.gameobject;
import math.vector, math.matrix, math.quaternion;

import std.conv;

mixin Properties;

class Transform
{
public:
	this( GameObject obj = null )
	{
		owner = obj;

		position = new Vector!3;
		rotation = new Quaternion;
		scale = new Vector!3( 1.0, 1.0, 1.0);

		updateMatrix();
	}

	~this()
	{
		destroy( position );
		destroy( rotation ); 
		destroy( scale );
	}

	alias property!owner_ owner;
	//alias setter!owner_ owner; // ditto

	mixin EmmittingProperty!( "Vector!3", "position", "public" );
	mixin EmmittingProperty!( "Quaternion", "rotation", "public" );
	mixin EmmittingProperty!( "Vector!3", "scale", "public" );

	/**
	 * This returns the object's position relative to the world origin, not the parent
	 */
	final @property Vector!3 worldPosition()
	{
		if( owner.parent is null )
			return position;
		else
			return owner.parent.transform.worldPosition + position;
	}

	/**
	* This returns the object's rotation relative to the world origin, not the parent
	*/
	final @property Quaternion worldRotation()
	{
		if( owner.parent is null )
			return rotation;
		else
			return owner.parent.transform.worldRotation * rotation;
	}

	final @property Matrix!4 matrix()
	{
		if( _matrixIsDirty )
			updateMatrix();

		if( owner.parent is null )
			return _matrix;
		else
			return owner.parent.transform.matrix * _matrix;
	}

	final void updateMatrix()
	{
		auto newMatrix = new Matrix!4;

		// Scale
		newMatrix.matrix[ 0 ][ 0 ] = scale.x;
		newMatrix.matrix[ 1 ][ 1 ] = scale.y;
		newMatrix.matrix[ 2 ][ 2 ] = scale.z;
		newMatrix.matrix[ 3 ][ 3 ] = 1.0f;

		// Rotate
		_matrix = newMatrix * rotation.matrix;

		// Translate
		_matrix.matrix[ 3 ][ 0 ] = position.x;
		_matrix.matrix[ 3 ][ 1 ] = position.y;
		_matrix.matrix[ 3 ][ 2 ] = position.z;

		_matrixIsDirty = false;
	}

private:
	GameObject owner_;
	Matrix!4 _matrix;
	bool _matrixIsDirty;
}
