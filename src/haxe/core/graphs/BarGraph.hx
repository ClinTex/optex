package core.graphs;

import core.graphs.ColorCalculator.ValueBasedColourCalculator;
import core.d3.D3;
import haxe.ui.core.Component;
import js.Browser;
import js.Syntax;
import js.html.DivElement;

class BarGraph extends Component {
    private var _container:DivElement = null;
    private var _graph:Dynamic = null;
    private var _graphGraphics:Dynamic = null;
    private var _xScale:Dynamic = null;
    private var _xAxis:Dynamic = null;
    private var _yScale:Dynamic = null;
    private var _yAxis:Dynamic = null;
    
    private var AXIS_COLOR:String = "#888888";
    private var ANIMATION_DURATION = 500;
    
    public var xAxisField = "group";
    public var yAxisField = "value";
    
    public var autoCalculateYAxisMax = true;
    public var yAxisMax = 10;
    
    public var hideXAxis:Bool = false;
    
    public var scheme:String = "blues";
    public var colorCalculator:ColorCalculator = null;
    public var sort = "desc";
    public var barSpacing:Float = 0.2;
    public var roundBarWidths:Bool = false;
    
    public function new() {
        super();
        colorCalculator = new ValueBasedColourCalculator();
        colorCalculator.scheme = scheme;
    }
    
    private var _margins:Dynamic = {top: 5, right: 2, bottom: 20, left: 30};
    public var margins(get, set):Dynamic;
    private function get_margins():Dynamic {
        return _margins;
    }
    private function set_margins(value:Dynamic):Dynamic {
        _margins = value;
        return value;
    }

    private var _data:Dynamic = null;
    public var data(get, set):Dynamic;
    private function get_data():Dynamic {
        return _data;
    }
    private function set_data(value:Dynamic):Dynamic {
        _data = value;
        calculateMaxY();
        if (_graph != null) {
            refreshData(true);
        }
        return value;
    }
    
    private function calculateMaxY() {
        if (autoCalculateYAxisMax == false) {
            return;
        }
        var dd:Array<Dynamic> = cast _data;
        var m = 0;
        for (d in dd) {
            var c = Reflect.field(d, yAxisField);
            if (c > m) {
                m = c;
            }
        }
        if (m % 2 != 0) {
            m++;
        }
        yAxisMax = m;
    }
    
    private override function onReady() {
        super.onReady();
        _container = Browser.document.createDivElement();
        this.element.appendChild(_container);
        
        _graph = D3.select(_container).append("svg");
        _graphGraphics = _graph.append("g");
        
        invalidateComponentLayout();
    }
    
    public function refreshData(animate:Bool = false) {
        if (_data == null) {
            return;
        }

        if (sort == "asc") {
            _data.sort(function(a, b) {
                var va = Reflect.field(a, yAxisField);
                var vb = Reflect.field(b, yAxisField);
                return (va - vb);
            });
        } else if (sort == "desc") {
            _data.sort(function(a, b) {
                var va = Reflect.field(a, yAxisField);
                var vb = Reflect.field(b, yAxisField);
                return (vb - va);
            });
        }
        
        refreshXAxis();
        refreshYAxis();
        
        var cx = width - margins.left - margins.right;
        var cy = height - margins.top - margins.bottom;
        
        var update:Dynamic = _graphGraphics.selectAll("rect").data(_data);
        
        update.exit()
            .transition()
            .duration(ANIMATION_DURATION)
            .attr("width", 0)
            .remove();
        
        var chain = update.enter()    
            .append("rect")
            .attr("x", getBarX)
            .attr("y", function(d) { return _yScale(D3.field(d, yAxisField)); })
            .attr("width", 0)
            .attr("height", function(d) { return cy - _yScale(D3.field(d, yAxisField)); });
        
        if (animate == true) {    
            chain = chain.transition()
                .duration(ANIMATION_DURATION);
        }

        chain.attr("x", getBarX)
            .attr("y", function(d) { return _yScale(D3.field(d, yAxisField)); })
            .attr("width", getBarWidth)
            .attr("height", function(d) { return cy - _yScale(D3.field(d, yAxisField)); })
            .attr("fill", getBarFill)
            .style("opacity", 1.7);
            
        //var chain:Dynamic = update.enter().append("rect").merge(update);
        var chain = update;
        if (animate == true) {
            chain = chain
                .transition()
                .duration(ANIMATION_DURATION);
        }
        
        chain.attr("x", getBarX)
            .attr("y", function(d) { return _yScale(D3.field(d, yAxisField)); })
            .attr("width", getBarWidth)
            .attr("height", function(d) { return cy - _yScale(D3.field(d, yAxisField)); })
            .attr("fill", getBarFill)
            .style("opacity", 1.7);
    }
    
    private function getBarX(d) {
        if (roundBarWidths == true) {
            return Math.ffloor(_xScale(D3.field(d, xAxisField)));
        }
        return _xScale(D3.field(d, xAxisField));
    }
    
    private function getBarWidth(d) {
        if (roundBarWidths == true) {
            return Math.fceil(_xScale.bandwidth()) + 1;
        }
        return _xScale.bandwidth();
    }
    
    private function getBarFill(d, i) {
        return colorCalculator.get(d, i, {
            valueMax: yAxisMax,
            valueField: yAxisField
        });
    }
    
    private override function validateComponentLayout():Bool {
        var b = super.validateComponentLayout();
        if (width > 0 && height > 0 && _graph != null) {
            var cx = width - margins.left - margins.right;
            var cy = height - margins.top - margins.bottom;
            
            _graph
                .attr("width", cx + margins.left + margins.right)
                .attr("height", cy + margins.top + margins.bottom);
                
            _graphGraphics
                .attr("transform", "translate(" + margins.left + "," + margins.top + ")");
            
            refreshData();
        }
        return b;
    }
    
    private function refreshXAxis() {
        if (_data == null) {
            return;
        }
        
        var cx = width - margins.left - margins.right;
        var cy = height - margins.top - margins.bottom;
        
        if (_xAxis != null) {    
            _xAxis.remove();
        }
        
        _xScale = D3.scaleBand()
            .range([ 0, cx ])
            .domain(_data.map(function(d) { return D3.field(d, xAxisField); }))
            .padding(barSpacing);
        _xAxis = _graphGraphics.append("g")
            .attr("transform", "translate(0," + cy + ")")
            .call(D3.axisBottom(_xScale));
        _xAxis.selectAll("path")
            .attr("stroke", AXIS_COLOR);
        _xAxis.selectAll("text")
            .attr("fill", AXIS_COLOR);
        _xAxis.selectAll("line")
            .attr("stroke", AXIS_COLOR);
            
        if (hideXAxis == true) {
            _xAxis.selectAll("text").remove();
            _xAxis.selectAll("line").remove();
        }
    }
    
    private function refreshYAxis() {
        if (_data == null) {
            return;
        }
        
        var cy = height - margins.top - margins.bottom;
        
        if (_yAxis != null) {    
            _yAxis.remove();
        }
        
        _yScale = D3.scaleLinear()
            .domain([0, yAxisMax])
            .range([ cy, 0]);
        _yAxis = _graphGraphics.append("g")    
            .attr("class", "myYaxis")
            .call(D3.axisLeft(_yScale));
        _yAxis.selectAll("path")
            .attr("stroke", AXIS_COLOR);
        _yAxis.selectAll("text")
            .attr("fill", AXIS_COLOR);
        _yAxis.selectAll("line")
            .attr("stroke", AXIS_COLOR);
    }

    private static var LETTERS:Array<String> = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "X", "Y", "Z"];
    public function createRandomData(count:Int = 20) {
        var randomData:Dynamic = [];
        for (n in 0...count) {
            randomData.push({
                group: LETTERS[n],
                value: Std.random(100) + 10
            });
        }

        this.data = randomData;
    }
}