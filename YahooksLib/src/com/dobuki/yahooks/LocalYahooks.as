package com.dobuki.yahooks
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	public class LocalYahooks extends BaseYahooks
	{
		private var _frame:uint = 0;
		private var rooms:Object = {};
		private var serverCalls:Array = [];
		private var callTimer:Timer = new Timer(0,1);
		
		static private var _instance:LocalYahooks = new LocalYahooks();
		
		public function LocalYahooks()
		{
			callTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
		}
		
		static public function get instance():IYahooks {
			return _instance;
		}		
		
		override public function connect(root:MovieClip, username:String=null, room:String=null, joinData:Object=null):void
		{
			super.connect(root,username,room,joinData);
			root.addEventListener(Event.ENTER_FRAME,loop);
		}
		
		override public function disconnect():void {
			root.removeEventListener(Event.ENTER_FRAME,loop);
			super.disconnect();
		}
		
		private function loop(e:Event):void {
			_frame++;
			for each (var hookInfo:HookInfo in _hookInfo) {
				if(hookInfo.loopFunction!=null) {
					hookInfo.loopFunction.call(hookInfo.hook,true);
				}
			}
		}
		
		override public function call(hook:Object, action:String, persist:Boolean, ...params):void
		{
			serverCalls.push([hook,action,params]);
			callTimer.start();
		}
		
		private function onTimer(e:TimerEvent):void {
			callTimer.reset();
			var array:Array = serverCalls;
			serverCalls = [];
			for each(var calls:Array in array) {
				var hook:Object = calls[0];
				var action:String = calls[1];
				var params:Array = calls[2];
				if(hook.hasOwnProperty(action)) {
					//	for consistency, it has to be called on every room joined
					var info:HookInfo = _hookInfo[hook];
					for(var roomId:String in rooms)
						if(!info.room || info.room==roomId)
							hook[action].apply(hook,params);
				}
			}
		}
		
		override public function get frame():uint
		{
			return _frame;
		}
		
		override public function leaveRoom(room:String):void 
		{
			delete rooms[room];
		}
		
		override public function joinRoom(room:String,joinData:Object=null):void 
		{
			rooms[room] = new Room();
			rooms[room].data = joinData?joinData:{};
			rooms[room].name = room;
			rooms[room].count = 1;
		}
		
		override public function listRooms(callback:Function):void {
			var timeout:int = setTimeout(
				function():void {
					var array:Array = [];
					for each (var room:Room in rooms)
					{
						array.push(room);
					}
					callback(array);
				},0);
		}		
	}
}