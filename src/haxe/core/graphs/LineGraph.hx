package core.graphs;

import haxe.ui.core.Component;
import js.html.DivElement;
import core.d3.D3;
import core.nvd3.NV;
import haxe.ui.util.GUID;
import js.Browser;

class LineGraph extends Component {
    private var _container:DivElement = null;
    private var _graph:Dynamic = null;
    private var _chart:Dynamic;
    
    public function new() {
        super();
    }
    
    private var _data:Array<Dynamic> = [];
    public var data(get, set):Array<Dynamic>;
    private function get_data():Array<Dynamic> {
        return _data;
    }
    private function set_data(value:Array<Dynamic>):Array<Dynamic> {
        _data = value;
        if (_graph != null) {
            _graph.datum(_data);
        }
        
        if (_chart != null) {
            _chart.update();
        }
        return value;
    }
    
    public function update() {
        if (_graph != null) {
            _graph.datum(_data);
        }
        
        if (_chart != null) {
            _chart.update();
        }
    }
    
    private override function onReady() {
        super.onReady();
        if (this.id == null) {
            this.id = GUID.uuid();
        }
        var containerId = this.id + "-container";
        _container = Browser.document.createDivElement();
        _container.id  = containerId;
        this.element.appendChild(_container);
        _graph = D3.select(_container).append("svg");
        onThemeChanged();
        
        NV.addGraph(function() {
            _chart = NV.models.lineChart();
            
            _graph.datum(_data).call(_chart);   
            
            return _chart;
        });
        
        invalidateComponentLayout();
     }
    
    private override function validateComponentLayout():Bool {
        var b = super.validateComponentLayout();
        resizeGraph();
        return b;
    }
     
    private function resizeGraph() {
        if (width > 0 && height > 0 && _graph != null) {
            var cx = Std.int(width);
            var cy = Std.int(height);
            _graph.attr("width", cx).attr("height", cy);
            if (_chart != null) {
                //_chart.duration(0);
                _chart.width(Std.int(cx));
                _chart.height(Std.int(cy));
                _chart.update();         
                //_chart.duration(250);
            }
        }
    }
}