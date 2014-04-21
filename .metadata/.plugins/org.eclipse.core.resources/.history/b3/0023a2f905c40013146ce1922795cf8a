package paris24.turbox
{
	import com.adobe.utils.AGALMiniAssembler;
	import com.senocular.utils.SWFReader;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix3D;
	
	import paris24.turbox.grafix.GrafixDigger;
	import paris24.turbox.grafix.GrafixProcessor;
	import paris24.turbox.utils.Clock;

	[Event(name="init", type="flash.events.Event")]
	public class Turbox extends EventDispatcher
	{
		private var container:DisplayObjectContainer;
		private var dispatcher:IEventDispatcher = new EventDispatcher();
		private var context3D:Context3D;
		private var program:Program3D;
		private var digger:GrafixDigger = new GrafixDigger();
		private var processor:GrafixProcessor = new GrafixProcessor();
		private var isActive:Boolean = false;
		private var bgColor:Vector.<Number>;
		
		static public var s:Stage;
		public function Turbox(container:DisplayObjectContainer)
		{
			
			var swf:SWFReader = new SWFReader(container.root.loaderInfo.bytes);
			bgColor = new <Number> [(swf.backgroundColor>>16)%256 / 256,(swf.backgroundColor>>8)%256 / 256,(swf.backgroundColor)%256 / 256];
			
			this.container = container;
			active = true;
			s = container.stage;
			var addedToStage:Function = function(e:Event):void {
				var stage:Stage = container.stage;
				stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, initMolehill);
				stage.stage3Ds[0].requestContext3D();
			}
			if(container.stage)
				addedToStage(null);
			else
				container.addEventListener(Event.ADDED_TO_STAGE,addedToStage);
		}
		
		private function initMolehill(e:Event):void {
			var stage:Stage = container.stage;
			var stage3D:Stage3D = e.currentTarget as Stage3D;
			context3D = stage3D.context3D;	
			
			processor.init(context3D);
			
			context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2, true);
			context3D.enableErrorChecking = true;
			
			context3D.setBlendFactors(
				Context3DBlendFactor.SOURCE_ALPHA,
				Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n"+
				"mov v0, va1"
			);			
			
			var fragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"tex ft1, v0, fs0 <2d,linear,miplinear>\n"+
				"mov oc, ft1"
			);
			
			program = context3D.createProgram();
			program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);	
			context3D.setProgram(program);
			
			var m:Matrix3D = new Matrix3D();
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, m, true);
			dispatchEvent(new Event(Event.INIT));
		}
		
		private function display(e:Event):void
		{
			if(context3D) {
				context3D.clear (bgColor[0], bgColor[1], bgColor[2]);
				var stage:Stage = container.stage;
	//			Clock.clockin('dig');
				var pix:Vector.<IBitmapDrawable> = digger.digGraphix(container);
	//			Clock.clockout('dig');
	//			Clock.clockin('process');
				processor.processGrafix(context3D,pix,stage.stageWidth,stage.stageHeight);			
	//			Clock.clockout('process');
	//			Clock.clockin('present');
				context3D.present();
	//			Clock.clockout('present');
			}
		}
		
		public function set standardSize(value:int):void {
			processor.standardSize = value;
		}
		
		public function loadClassInfoXML(xml:XML):void {
			digger.loadClassInfoXML(xml);
		}
		
		public function set verbose(value:Boolean):void {
			digger.verbose = true;
		}
		
		public function get active():Boolean {
			return isActive;
		}
		
		public function set active(value:Boolean):void {
			if(isActive != value) {
				isActive = value;
				if(isActive) {
					if(container.visible) {
						container.visible = false;
						container.cacheAsBitmap = true;
						container.mouseChildren = container.mouseEnabled = false;
					}
					container.addEventListener(Event.FRAME_CONSTRUCTED,display);
				}
				else {
					if(context3D)
						context3D.clear();
					context3D.present();
					if(!container.visible) {
						container.visible = true;
						container.cacheAsBitmap = false;
						container.mouseChildren = container.mouseEnabled = true;
					}
					container.removeEventListener(Event.FRAME_CONSTRUCTED,display);
				}
			}
		}
	}
}