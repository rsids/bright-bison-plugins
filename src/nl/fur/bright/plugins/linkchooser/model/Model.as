package nl.fur.bright.plugins.linkchooser.model {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import nl.bs10.brightlib.events.BrightEvent;
	
	
	public class Model extends EventDispatcher {
		
		private var _callback:Function;
		private var _internalOnly:Boolean;
		private var _showAdvancedOptions:Boolean;
		
		private var _allowedTemplates:Array;
		
		private var _title:String;
		private var _target:String;
		
		/**
		 * When loading as a popup, the properties are set before the listener is attached,
		 * we then check this variable
		 */
		public var propertiesSet:Boolean;
		
		public function Model():void {
			super();			
		}
		
		private static var _model:Model;
		public static function get instance():Model {
			if(_model == null ) _model = new Model();
			return _model;
		}
		
		public function dispatch(type:String, data:Object = null):void {
			dispatchEvent(new BrightEvent(type, data));
		}

		public function get internalOnly():Boolean
		{
			return _internalOnly;
		}

		[Bindable(event="internalOnlyChanged")]
		public function set internalOnly(value:Boolean):void
		{
			if(value != _internalOnly) {
				_internalOnly = value;
				dispatchEvent(new Event("internalOnlyChanged"));
			}
		}

		public function get showAdvancedOptions():Boolean
		{
			return _showAdvancedOptions;
		}
		
		[Bindable(event="showAdvancedOptionsChanged")]
		public function set showAdvancedOptions(value:Boolean):void {
			
			if(value != _showAdvancedOptions) {
				_showAdvancedOptions = value;
				dispatchEvent(new Event("showAdvancedOptionsChanged"));
			}
		}

		public function get callback():Function
		{
			return _callback;
		}

		public function set callback(value:Function):void
		{
			_callback = value;
		}

		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

		public function get target():String
		{
			return _target;
		}

		public function set target(value:String):void
		{
			_target = value;
		}
		
		[Bindable(event="allowedTemplatesChanged")]
		public function set allowedTemplates(value:Array):void {
			if(value !== _allowedTemplates) {
				_allowedTemplates = value;
				dispatchEvent(new Event("allowedTemplatesChanged"));
			}
		}
		
		/** 
		 * Getter/Setter methods for the allowedTemplates property
		 **/
		public function get allowedTemplates():Array {
			return _allowedTemplates;
		}


	}
}