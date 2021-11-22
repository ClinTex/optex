package core.graphs;

import core.d3.D3;
import haxe.ui.Toolkit;
import haxe.ui.backend.html5.util.StyleSheetHelper;
import haxe.ui.core.Component;
import haxe.ui.util.GUID;
import js.Browser;
import js.Syntax;
import js.html.CSSStyleSheet;
import js.html.DivElement;
import core.nvd3.NV;
import haxe.ui.events.UIEvent;

class BarGraphEvent extends UIEvent {
    public static inline var BAR_SELECTED:String = "barSelected";
    public static inline var BAR_UNSELECTED:String = "barUnselected";
    
    public var barIndex:Int;
    
    public override function clone():UIEvent {
        var c:BarGraphEvent = new BarGraphEvent(this.type);
        c.barIndex = this.barIndex;
        c.data = this.data;
        postClone(c);
        return c;
    }
}

class BarGraph extends Component {
    private var _container:DivElement = null;
    private var _graph:Dynamic = null;
    private var _chart:Dynamic;
    
    public var xAxisField:String = "x";
    public var yAxisField:String = "y";
    
    public var xAxisColour:String = "#b4b4b4";
    public var yAxisColour:String = "#b4b4b4";
    public var gridColour:String = "#242729";
    public var textColour:String = "#b4b4b4";
    public var markerColour:String = "#ffffff";
    
    public var labelRotation:Float = 0;
    
    private var _colourCalculator:ColorCalculator = null;
    public var colourCalculator(get, set):ColorCalculator;
    private function get_colourCalculator():ColorCalculator {
        return _colourCalculator;
    }
    private function set_colourCalculator(value:ColorCalculator):ColorCalculator {
        _colourCalculator = value;
        if (_chart != null && value != null) {
            _chart.barColor(calculateColour);
            //this.data = _data;
        }
        return value;
    }
    
    public function new() {
        super();
    }
    
    private static var counter:Int = 0;
    private override function onReady() {
        super.onReady();
        if (this.id == null) {
            this.id = "bar-graph-" + counter;
            counter++;
        }
        var containerId = this.id + "-container";
        _container = Browser.document.createDivElement();
        _container.id  = containerId;
        this.element.appendChild(_container);
        _graph = D3.select(_container).append("svg");
        onThemeChanged();
        
        NV.addGraph(function() {
            _chart = NV.models.multiBarChart();
            _chart.x(function(d) { return D3.field(d, xAxisField); });
            _chart.y(function(d) { return D3.field(d, yAxisField); });
            _chart.staggerLabels(false);
            _chart.reduceXTicks(false);
            _chart.rotateLabels(labelRotation);
            _chart.showControls(false);
            _chart.tooltip.enabled(false);
            if (_colourCalculator != null) {
                _chart.barColor(calculateColour);
            }
            
            _graph.datum(_data).call(_chart);   
            
            _chart.dispatch.on('renderEnd', function(){
                drawMarker();
            });

            _chart.multibar.dispatch.on("elementClick", function(e:Dynamic) {
                var index:Int = e.index;
                if (index == _selectedBarIndex) {
                    unselectBars();
                    var event = new BarGraphEvent(BarGraphEvent.BAR_UNSELECTED);
                    event.barIndex = index;
                    dispatch(event);
                    return;
                }
        
                selectBar(index);
            });
        
            //resizeGraph();
            return _chart;
        });
        invalidateComponentLayout();
    }

    private var _selectedBarIndex:Int = -1;
    public function selectBar(barIndex:Int) {
        var barCount = _data.length;
        var dataCount = _data[0].values.length;
        
        _selectedBarIndex = barIndex;
        var event = new BarGraphEvent(BarGraphEvent.BAR_SELECTED);
        event.barIndex = barIndex;
        var eventData:Dynamic = {
            seriesData: []
        }
        for (n in 0...barCount) {
            if (eventData.xValue == null) {
                eventData.xValue = _data[n].values[barIndex].x;
            }
            eventData.seriesData.push(_data[n].values[barIndex]);
        }
        event.data = eventData;
        dispatch(event);
        
        
        var g = D3.select("#" + _container.id + " svg .nvd3");
        var bars = g.selectAll(".nv-bar");
        bars.each(function(d, i) {
            var el = Syntax.code("this");
            if (i == barIndex || i == barIndex + dataCount) {
                el.classList.remove("dim");
            } else {
                el.classList.add("dim");
            }
        });
    }

    public function selectBarFromData(value:Any) {
        var series:Array<Dynamic> = _data[0].values;
        var index = -1;
        var n = 0;
        for (d in series) {
            if (d.x == value) {
                index = n;
                break;
            }
            n++;
        }
        
        if (index != -1) {
            selectBar(index);
        }
    }
    
    public function unselectBars() {
        _selectedBarIndex = -1;
        var g = D3.select("#" + _container.id + " svg .nvd3");
        var bars = g.selectAll(".nv-bar");
        bars.each(function(d, i) {
            var el = Syntax.code("this");
            el.classList.remove("dim");
        });
    }

    private function calculateColour(data:Dynamic) {
        return _colourCalculator.get(data, 0, {
            xAxisField: xAxisField,
            yAxisField: yAxisField,
        });
    }
    
    public var getMarkerValueY:Dynamic->Int->Float = null;
    private function drawMarker() {
        if (_container == null || _graph == null || _chart == null) {
            return;
        }
        
        removeMarker();
        if (getMarkerValueY == null) {
            return;
        }
        
        var g = D3.select("#" + _container.id + " svg .nvd3");
        var xValueScale = _chart.xAxis.scale();
        var yValueScale = _chart.yAxis.scale();

        var bbox = _graph.select(".nv-bar").node().getBBox();
        var cx = bbox.width * _data.length;
        
        var yValuePrev = null;
        for (i in 0...Std.int(_data[0].values.length)) {
            var item = [];
            for (d in _data) {
                item.push(d.values[i]);
            }
            var yValue = getMarkerValueY(item, i);
            if (i == 0) {
                yValuePrev = yValue;
                continue;
            }
            
            var key = D3.field(_data[0].values[i - 1], xAxisField);
            var nextKey = D3.field(_data[0].values[i], xAxisField);
            var y1 = yValueScale(yValuePrev);
            var y2 = yValueScale(yValue);
            yValuePrev = yValue;
            
            var offset = (cx / 2);
            g.append("line")
                .attr("id", "markerLine")
                .style("stroke", markerColour)
                .style("stroke-width", "2.0px")
                .style("stroke-dasharray", "5,5")
                .attr("x1", xValueScale(key) + offset)
                .attr("y1", y1)
                .attr("x2", xValueScale(nextKey) + offset)
                .attr("y2", y2);
            g.append("circle")
                .attr("id", "markerLine")
                .attr("cx", xValueScale(key) + offset)
                .attr("cy", y1)
                .attr("r", "3px")
                .style("fill", markerColour);
            g.append("circle")
                .attr("id", "markerLine")
                .attr("cx", xValueScale(nextKey) + offset)
                .attr("cy", y2)
                .attr("r", "3px")
                .style("fill", markerColour);
        }
    }
    
    public function removeMarker() {
        if (_container == null) {
            return;
        }
        var g = D3.select("#" + _container.id + " svg .nvd3");
        g.selectAll("#markerLine").remove();
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
                _chart.duration(0);
                _chart.width(Std.int(cx));
                _chart.height(Std.int(cy));
                _chart.update();         
                _chart.duration(250);
            }
        }
    }
    
    private var _data:Array<Dynamic> = [];
    public var data(get, set):Array<Dynamic>;
    private function get_data():Array<Dynamic> {
        return _data;
    }
    private function set_data(value:Array<Dynamic>):Array<Dynamic> {
        removeMarker();

        _data = value;

        if (_graph != null) {
            _graph.datum(_data);
        }
        
        if (_chart != null) {
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
        drawMarker();
    }
}