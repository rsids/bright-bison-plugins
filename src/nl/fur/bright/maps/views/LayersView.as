package nl.fur.bright.maps.views
{
	import mx.collections.ArrayCollection;
	import mx.containers.Panel;
	import mx.controls.DataGrid;
	
	import nl.bs10.brightlib.events.BrightEvent;
	import nl.bs10.brightlib.objects.Layer;

	public class LayersView extends Panel {
		
		[Bindable] public var layers:ArrayCollection = new ArrayCollection();
		[Bindable] public var layers_dg:DataGrid;


		public function LayersView() {
			super();
		}
		
		protected function addLayer():void {
			var ev:BrightEvent = new BrightEvent(BrightEvent.DATAEVENT, {type:"openLayerExplorer", multiple:true, callback:_callbackFn});
			parentDocument.dispatchEvent(ev); 
		}
		
		protected function deleteLayer():void {
			if(!layers_dg.selectedItem)
				return;
				
			parentDocument.removeMarkers(layers_dg.selectedItem.layerId);
			layers.removeItemAt(layers.getItemIndex(layers_dg.selectedItem));
			layers.refresh();
		}
		
		private function _callbackFn(value:Array):void {
			var isnew:Boolean = (layers.length == 0);
				layers
			// Check for duplicates
			for each(var layer:Layer in value) {
				var exists:Boolean = false;
				if(!isnew) {
					for each(var l2:Layer in layers) {
						if(l2.layerId == layer.layerId) {
							exists = true;
							break;
						}
					}
				}
				if(!exists) {
					layer.visible = true;
					layers.addItem(layer);
					parentDocument.getMarkers(layer.layerId);
				}
			}
			
			layers.refresh();
		}
	}
}