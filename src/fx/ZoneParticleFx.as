package fx
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import manager.AssetManager;
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.actions.TargetScale;
	import org.flintparticles.common.counters.PerformanceAdjusted;
	import org.flintparticles.common.easing.Quadratic;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.common.initializers.ScaleImageInit;
	import org.flintparticles.common.initializers.SharedImages;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.initializers.Position;
	import org.flintparticles.twoD.initializers.Velocity;
	import org.flintparticles.twoD.renderers.BitmapRenderer;
	import org.flintparticles.twoD.zones.BitmapDataZone;
	import org.flintparticles.twoD.zones.DiscSectorZone;
	
	/**
	 * ...
	 * @author Nicolas Bonnefoy
	 */
	public class ZoneParticleFx extends Sprite
	{
		
		public var emitter:Emitter2D;
		public var renderer:BitmapRenderer;
		public var bitmapData:BitmapData;
		private var numPart:uint;
		
		private var scale:Number;
		
		public function ZoneParticleFx(zone:BitmapData, numParticle:uint = 60) {
			bitmapData = zone;
			numPart = numParticle;
			
			mouseChildren = mouseEnabled = false;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void	{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			startEngine();
		}
		
		public function kill():void	{
			if (!emitter) {
				return;
			}
			// free up resources
			graphics.clear();
			emitter.stop();
			emitter.killAllParticles();
			emitter = null;
			
			removeChild(renderer);
			renderer = null;
		}
		
		//----- Particle System Setup -----
		
		private function startEngine():void {
			// initialize engine
			emitter = new Emitter2D();
			renderer = new BitmapRenderer(new Rectangle(-25, -25, bitmapData.width+50, bitmapData.height+50));
			addChild(renderer);
			renderer.addEmitter(emitter);
			
			renderer.blendMode = BlendMode.ADD;
			// set up startEmitter
			emitter.counter = new PerformanceAdjusted(numPart, numPart, 60);
			
			// define appearance of particles
			emitter.addInitializer(new SharedImages([AssetManager.getInstance().getImage("flare1"), AssetManager.getInstance().getImage("flare2"), AssetManager.getInstance().getImage("flare3")]));
			emitter.addInitializer(new Position(new BitmapDataZone(bitmapData)));
			emitter.addInitializer(new Velocity(new DiscSectorZone(new Point(0, 0), 25, 10, -Math.PI * 0.75, -Math.PI * 0.25)));
			emitter.addInitializer( new ScaleImageInit(0.5, 1));
			emitter.addAction(new Age(Quadratic.easeInOut));
			emitter.addAction(new Move());
			emitter.addAction(new TargetScale(0, 1));
			
			emitter.addInitializer(new Lifetime(1.5));
			// start engine
			//emitter.runAhead(1, 30);
			emitter.start();
		}
		
	}
}

