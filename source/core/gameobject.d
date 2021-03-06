/**
 * Defines the GameObject class, to be subclassed by scripts and instantiated for static objects.
 */
module core.gameobject;
import core.prefabs, core.properties;
import components;
import graphics.graphics, graphics.shaders;
import utility.config;
import math.transform, math.vector, math.quaternion;

import yaml;

import std.signals, std.conv, std.variant;

class GameObject
{
public:
	/**
	 * The current transform of the object.
	 */
	mixin Property!( "Transform", "transform", "public" );
	/**
	 * The Material belonging to the object
	 */
	mixin Property!( "Material", "material", "public" );
	/**
	 * The Mesh belonging to the object
	 */
	mixin Property!( "Mesh", "mesh", "public" );
	/**
	 * The object that this object belongs to
	 */
	mixin Property!( "GameObject", "parent" );
	/**
	 * All of the objects which list this as parent
	 */
	mixin Property!( "GameObject[]", "children" );

	mixin Signal!( string, string );

	/**
	 * Create a GameObject from a Yaml node.
	 */
	static GameObject createFromYaml( Node yamlObj )
	{
		GameObject obj;
		Variant prop;
		Node innerNode;

		// Try to get from script
		if( Config.tryGet!string( "Script.ClassName", prop, yamlObj ) )
		{
			obj = cast(GameObject)Object.factory( prop.get!string );
		}
		else if( Config.tryGet!string( "InstanceOf", prop, yamlObj ) )
		{
			obj = Prefabs[ prop.get!string ].createInstance();
		}
		else
		{
			obj = new GameObject;
		}

		if( Config.tryGet!string( "Camera", prop, yamlObj ) )
		{
			//TODO: Setup camera
		}

		if( Config.tryGet!string( "Material", prop, yamlObj ) )
		{
			obj.addComponent( Assets.get!Material( prop.get!string ) );
		}

		if( Config.tryGet!string( "Mesh", prop, yamlObj ) )
		{
			obj.addComponent( Assets.get!Mesh( prop.get!string ) );
		}

		if( Config.tryGet( "Transform", innerNode, yamlObj ) )
		{
			Vector!3 transVec;
			if( Config.tryGet( "Scale", transVec, innerNode ) )
				obj.transform.scale = transVec;
			if( Config.tryGet( "Position", transVec, innerNode ) )
				obj.transform.position = transVec;
			if( Config.tryGet( "Rotation", transVec, innerNode ) )
				obj.transform.rotation = Quaternion.fromEulerAngles( transVec );
		}

		return obj;
	}

	/**
	 * Creates basic GameObject with transform and connection to transform's emitter.
	 */
	this()
	{
		transform = new Transform( this );
		transform.connect( &emit );
	}

	~this()
	{
		destroy( transform );
	}

	/**
	 * Called once per frame to update all components.
	 */
	final void update()
	{
		onUpdate();

		foreach( ci, component; componentList )
			component.update();
	}

	/**
	 * Called once per frame to draw all components.
	 */
	final void draw()
	{
		onDraw();

		Graphics.drawObject( this );
	}

	/**
	 * Called when the game is shutting down, to shutdown all components.
	 */
	final void shutdown()
	{
		onShutdown();

		/*foreach_reverse( ci, component; componentList )
		{
			component.shutdown();
			componentList.remove( ci );
		}*/
	}

	/**
	 * Adds a component to the object.
	 */
	final void addComponent( T )( T newComponent ) if( is( T : Component ) )
	{
		componentList[ T.classinfo ] = newComponent;

		// Add component to proper property
		if( typeid( newComponent ) == typeid( Material ) )
			material = cast(Material)newComponent;
		else if( typeid( newComponent ) == typeid( Mesh ) )
			mesh = cast(Mesh)newComponent;
	}

	/**
	 * Gets a component of the given type.
	 */
	final T getComponent( T )() if( is( T : Component ) )
	{
		return componentList[ T.classinfo ];
	}

	final void addChild( GameObject object )
	{
		object._children ~= object;
		object.parent = this;
	}

	/// Called on the update cycle.
	void onUpdate() { }
	/// Called on the draw cycle.
	void onDraw() { }
	/// Called on shutdown.
	void onShutdown() { }
	/// Called when the object collides with another object.
	void onCollision( GameObject other ) { }

private:
	Component[ClassInfo] componentList;
}
