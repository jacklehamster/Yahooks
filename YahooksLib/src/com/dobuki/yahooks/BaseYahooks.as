package com.dobuki.yahooks
{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	public class BaseYahooks implements IYahooks
	{
		protected var root:MovieClip;
		protected var _hooks:Object = {};
		protected var _hookInfo:Dictionary = new Dictionary();

		protected var _username:String;

		public function BaseYahooks()
		{
		}
		
		public function connect(root:MovieClip, username:String=null, room:String=null, joinData:Object=null):void
		{
			this.root = root;
			this._username = username;
			if(room) {
				joinRoom(room,joinData);
			}
		}
		
		public function disconnect():void {
			
			root = null;
			_hooks = {};
			_hookInfo = new Dictionary();
		}
		
		public function get username():String {
			return _username;
		}

		public function register(hook:Object, id:String, room:String=null):void
		{
			var info:HookInfo = new HookInfo();
			_hookInfo[hook] = info;
			info.id = id;
			info.room = room;
			info.hook = hook;
			_hooks[info.id] = hook;
		}

		public function unregister(hook:Object):void {
			var info:HookInfo = _hookInfo[hook];
			delete _hookInfo[hook];
			if(info && info.id)
				delete _hooks[info.id];
		}

		public function setLoop(hook:Object, callback:Function):void
		{
			var info:HookInfo = _hookInfo[hook];
			info.loopFunction = callback;
		}
		
		public function setRoom(hook:Object,room:String):void {
			var info:HookInfo = _hookInfo[hook];
			info.room = room;
		}
		
		public function setLeaveCallback(hook:Object, callback:Function):void
		{
			var info:HookInfo = _hookInfo[hook];
			info.leaveFunction = callback;
		}
		
		public function setJoinCallback(hook:Object, callback:Function):void
		{
			var info:HookInfo = _hookInfo[hook];
			info.joinFunction = callback;
		}

		public function setLeaderboardCallback(hook:Object, callback:Function):void
		{
			var info:HookInfo = _hookInfo[hook];
			info.leaderboardFunction = callback;
		}

		public function setRankCallback(hook:Object, callback:Function):void
		{
			var info:HookInfo = _hookInfo[hook];
			info.rankFunction = callback;
		}
		
		public function submitScore(name:String,score:int):void
		{
			
		}
		
		public function leaveRoom(room:String):void 
		{
		}
		
		public function joinRoom(room:String,joinData:Object=null):void 
		{
		}

		public function listRooms(callback:Function):void 
		{
		}

		public function call(hook:Object, action:String, persist:Boolean, ...params):void
		{
		}
		
		public function get frame():uint
		{
			return 0;
		}
	}
}