package manager 
{
	import controller.base.PopupController;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import org.osflash.signals.Signal;
	/**
	 * Centralize errors
	 * Can display error popup if critical error is encoutered
	 * @author Nicolas Bonnefoy
	 */
	public class GlobalErrorHandler 
	{
		
		public static var onError:Signal = new Signal(String);
		
		public static var displayTarget:DisplayObjectContainer;
		public static var autoDisplayPopups:Boolean = true;
		
		/**
		 * Dispatch an error and a custom message
		 * @param	err
		 * @param	msg
		 */
		public static function dispatch(err:*, msg:String = null):void {
			var arr:Array = [];
			arr.push(' ');
			if (msg) {
				arr.push('<p align="center"><font color="#F97C00">' + msg + '</font></p>');
			}
			
			if (err is Error) {
				arr.push('<font color="#F97C00">[' + err.name +'] </font>' + typeof(err) + ": #" + err.errorID);
				arr.push(err.message);
            } 
			else if (err is ErrorEvent) {
				arr.push('<font color="#F97C00">[' + err.type +'] </font>' + typeof(err.currentTarget) + " : #" + err.errorID);
				arr.push('<font color="#F97C00">[target] </font>' + String(err.target) +" : " + typeof(err.target));
				arr.push('<font color="#F97C00">[currentTarget] </font>' + String(err.currentTarget) +" : " + typeof(err.currentTarget));
				arr.push(err.text);
            } 
			else {
				arr.push('<font color="#F97C00">[Unknown Error] </font>' + err.type + ": #" + err.errorID);
				arr.push(err.toString());
            }
			arr.push(' ');
			
			onError.dispatch(arr.join('\n'));
			if (autoDisplayPopups && displayTarget) {
				displayPopup(arr.join('\n'), displayTarget);
			}
			
		}
		
		/**
		 * Display an error popup over any dispaly object,
		 * used by dispatch() when autoDisplayPopups is set to true.
		 * @param	msg
		 * @param	target
		 * @return
		 */
		public static function displayPopup(msg:String, target:DisplayObjectContainer):PopupController {
			var dsp:MovieClip = new MovieClip();
			var tf:TextField = new TextField();
			tf.multiline = true;
			tf.width = 500;
			tf.defaultTextFormat = new TextFormat("_sans", 13, 0xFFD5AA,false, false, false, null, null, TextFormatAlign.LEFT, 20,20,0,1.2);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.background = true;
			tf.backgroundColor = 0x000000;
			tf.border = true;
			tf.borderColor = 0xff0000;
			tf.htmlText = msg;
			dsp.addChild(tf);
			
			//autocenter
			var pop:PopupController = new PopupController(dsp);
			pop.hasShader = true;
			pop.onReady.addOnce(function ():void {
				dsp.x = (pop.display.stage.stageWidth - dsp.width) * 0.5;
				dsp.y = (pop.display.stage.stageHeight - dsp.height) * 0.5;
			});
			
			target.addChild(pop.display);
			
			return pop;
		}
	}

}