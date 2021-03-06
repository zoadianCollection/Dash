/**
 * Defines the DGame class, the base class for all game logic.
 */
module core.dgame;
import core.prefabs, core.properties;
import components.assets;
import graphics.graphics;
import utility.time, utility.config, utility.output, utility.input;

enum GameState { Menu = 0, Game = 1, Reset = 2, Quit = 3 };

class DGame
{
public:
	static
	{
		mixin Property!( "DGame", "instance" );
	}

	GameState currentState;

	/**
	 * Overrideable. Returns the name of the window.
	 */
	@property string title()
	{
		return "Dash";
	}

	/**
	 * Main Game loop.
	 */
	final void run()
	{
		// Init tasks
		//TaskManager.initialize();

        start();

        // Loop until there is a quit message from the window or the user.
        while( currentState != GameState.Quit && currentState != GameState.Reset )
        {
			//////////////////////////////////////////////////////////////////////////
			// Update
			//////////////////////////////////////////////////////////////////////////

			// Platform specific program stuff
			Graphics.messageLoop();

			// Update time
			Time.update();

			// Update input
			Input.update();

			// Update physics
			//if( currentState == GameState.Game )
			//	PhysicsController.stepPhysics( Time.deltaTime );

			// Do the updating of the child class.
			onUpdate();

			//////////////////////////////////////////////////////////////////////////
			// Draw
			//////////////////////////////////////////////////////////////////////////

			// Begin drawing
			Graphics.beginDraw();

			// Draw in child class
			onDraw();

			// End drawing
			Graphics.endDraw();
        }

		if( currentState == GameState.Reset )
			saveState();

        stop();
	}

	//static Camera camera;

protected:
	/**
	 * To be overridden, logic for when the game is being initalized.
	 */
	void onInitialize() { }
	/**
	 * To be overridden, called once per frame during the update cycle.
	 */
	void onUpdate() { }
	/**
	 * To be overridden, called once per frame during the draw cycle.
	 */
	void onDraw() { }
	/**
	 * To be overridden, called when the came is closing.
	 */
	void onShutdown() { }
	/**
	 * To be overridden, called when resetting and the state must be saved.
	 */
	void onSaveState() { }

	//UserInterface ui;

private:
	/**
	 * Function called to initialize controllers.
	 */
	final void start()
	{
		currentState = GameState.Menu;
        //camera = null;

		Config.initialize();
		Output.initialize();
		Graphics.initialize();
		Assets.initialize();
		Prefabs.initialize();
		//Physics.initialize();

        //ui = new UserInterface( this );

        onInitialize();
	}

	/**
	 * Function called to shutdown controllers.
	 */
	final void stop()
	{
		onShutdown();
		Assets.shutdown();
		Graphics.shutdown();
	}

	/**
	 * Called when engine is resetting.
	 */
	final void saveState()
	{
		onSaveState();
	}
}

struct Game( T ) if( is( T : DGame ) )
{
	static this()
	{
		DGame.instance = new T;
	}
}
