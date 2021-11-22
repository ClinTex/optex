package core.graphs;

import core.d3.D3;
import haxe.ui.Toolkit;
import haxe.ui.backend.html5.util.StyleSheetHelper;
import haxe.ui.core.Component;
import haxe.ui.util.GUID;
import js.Browser;
import js.html.CSSStyleSheet;
import js.html.DivElement;
import core.nvd3.NV;

class ScatterGraph extends Component {
    private var _container:DivElement = null;
    private var _graph:Dynamic = null;
    private var _chart:Dynamic;
    
    public var xAxisColour:String = "#b4b4b4";
    public var yAxisColour:String = "#b4b4b4";
    public var gridColour:String = "#181a1b";
    public var textColour:String = "#b4b4b4";
    public var markerColour:String = "#ffffff";
    
    public function new() {
        super();
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
        //buildColours(containerId);
        onThemeChanged();

        NV.addGraph(function() {
            _chart = NV.models.scatterChart();
            _chart.showDistX(true);
            _chart.showDistY(false);
            _chart.margin({bottom: 70});
            _chart.xAxis.staggerLabels(false);
            _chart.xAxis.rotateLabels(-45);
            _chart.tooltip.enabled(false);

            _chart.xAxis.tickValues(buildXValues()).tickFormat(function(d){
                return buildXLabels()[d];
            });
            
            _graph.datum(_data).call(_chart);

            return _chart;
        });

        invalidateComponentLayout();
    }

    private function buildXValues() {
        if (_data == null || _data.length == 0) {
            return [];
        }
        var values = [];
        var seriesCount = _data.length;
        var set:Array<Dynamic> = _data[0].values;
        var n = -1;
        //values.push(-1);
        for (item in set) {
            values.push(n);
            n++;
        }
        //values.push(n);
        return values;
    }
    
    private var _xLabels = null;
    private function buildXLabels() {
        if (_data == null || _data.length == 0) {
            return [];
        }

        if (_xLabels != null) {
            return _xLabels;
        }
        var labels = [];
        var set:Array<Dynamic> = _data[0].values;
        //labels.push("");
        for (item in set) {
            labels.push(item.originalX);
        }
        //labels.push("");
        _xLabels = labels;
        labels.shift();
        return labels;
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
                //_graph.datum(_data).call(_chart);   
                //_chart.duration(250);
            }
        }
    }
    
    private function fixData(data:Array<Dynamic>) {
        if (data == null || data.length == 0) {
            return data;
        }

        var fixedData = [];
        for (series in data) {
            var fixedValues:Array<Dynamic> = [];
            var values:Array<Dynamic> = series.values;
            var n = 0;
            
            fixedValues.push({
                originalX: "",
                x: -1,
                y: 0,
                size: 0
            });
            for (item in values) {
                trace(item);
                fixedValues.push({
                    originalX: item.x,
                    x: n,
                    y: item.y,
                    size: item.size
                });
                n++;
            }
            fixedValues.push({
                originalX: "",
                x: n,
                y: 0,
                size: 0
            });
            
            fixedData.push({
                key: series.key,
                values: fixedValues
            });
        }
        
        return fixedData;
    }

    private var _data:Array<Dynamic> = [];
    public var data(get, set):Array<Dynamic>;
    private function get_data():Array<Dynamic> {
        return _data;
    }
    private function set_data(value:Array<Dynamic>):Array<Dynamic> {
        trace(value);
        _data = fixData(value);
        if (_graph != null) {
            _graph.datum(_data);
        }
        
        if (_chart != null) {
            _chart.xAxis.tickValues(buildXValues()).tickFormat(function(d){
                return buildXLabels()[d];
            });

            _chart.update();
        }
        return value;
    }
    
    private var _coloursBuilt:Bool = false;
    private function buildColours(containerId:String) {
        if (_coloursBuilt == true) {
            return;
        }
        
        _coloursBuilt = true;
        try {
            var sheet:CSSStyleSheet = StyleSheetHelper.getValidStyleSheet();
                sheet.insertRule('#${containerId} .nvd3 .nv-axis line {
                    stroke: ${gridColour};
                }', sheet.cssRules.length);
                sheet.insertRule('#${containerId} .nvd3 .nv-axis path {
                    stroke: ${yAxisColour};
                    stroke-opacity: 1;
                }', sheet.cssRules.length);
                sheet.insertRule('#${containerId} .nvd3 .nv-zeroLine line {
                    stroke: ${xAxisColour} !important;
                    stroke-opacity: 1;
                }', sheet.cssRules.length);
                sheet.insertRule('#${containerId} .nvd3 .nv-y .tick.zero line {
                    stroke: ${yAxisColour};
                    stroke-opacity: 1;
                }', sheet.cssRules.length);
                
                sheet.insertRule('#${containerId} .nvd3 .nv-group {
                    transform: translate(0px, -1px);
                }', sheet.cssRules.length);

                sheet.insertRule('#${containerId} .nvd3 text {
                    fill: ${textColour};
                }', sheet.cssRules.length);
                
                sheet.insertRule('#${containerId} .nvd3 .nv-bar.dim {
                    opacity: .3;
                }', sheet.cssRules.length);
        } catch (e:Dynamic) {
            trace(e);
        }
    }
    
    public override function onThemeChanged() {
        super.onThemeChanged();
        
        if (Toolkit.theme == "dark") {
            xAxisColour = "#b4b4b4";
            yAxisColour = "#b4b4b4";
            gridColour = "#242729";
            textColour = "#b4b4b4";
            markerColour = "#ffffff";
        } else {
            xAxisColour = "#222222";
            yAxisColour = "#222222";
            gridColour = "#EEEEEE";
            textColour = "#222222";
            markerColour = "#444444";
        }
        
        _coloursBuilt = false;
        buildColours(_container.id);
    }
}