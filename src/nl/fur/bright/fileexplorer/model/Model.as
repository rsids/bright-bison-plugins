package nl.fur.bright.fileexplorer.model {
	
	import nl.fur.bright.fileexplorer.model.vo.*;
	import nl.fur.vein.model.BaseModel;
	
	public class Model extends BaseModel  {
		
		
		[Bindable] public var filesVO:FilesVO = new FilesVO();
		
		public function Model():void {
			super();			
		}
		
		private static var _model:Model;
		public static function get instance():Model {
			if(_model == null ) _model = new Model();
			return _model;
		}
	}
}