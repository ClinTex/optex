package core.graphs;

import haxe.ui.backend.html5.HtmlUtils;
import haxe.ui.core.Component;
import js.Browser;
import js.html.CanvasElement;
import js.html.DivElement;
import core.nvd3.Gauge;

class GaugeGraph extends Component {
	private var _container:CanvasElement;
    private var _gauge:Gauge = null;
    private var _textfield:DivElement;

	public function new() {
		super();
	}

	private override function onReady() {
		super.onReady();
		_container = Browser.document.createCanvasElement();
        _container.style.opacity = ".7";
		this.element.appendChild(_container);

        _textfield = Browser.document.createDivElement();
        _textfield.style.position = "absolute";
        _textfield.style.left = "0px";
        _textfield.style.bottom = "10px";
        _textfield.style.textAlign = "center";
        _textfield.style.width = "100%";
        _textfield.style.fontSize = "26px";
        _textfield.style.color = "#9292a0";
		this.element.appendChild(_textfield);
		invalidateComponent();

		var opts:Dynamic = {
			angle: 0, // The span of the gauge arc
			lineWidth: 0.44, // The line thickness
			radiusScale: 1, // Relative radius
			pointer: {
				length: 0.5, // // Relative to gauge radius
				strokeWidth: 0.035, // The thickness
				color_OLD: '#cacad1', // Fill color
				color: '#00000000' // Fill color
			},
			limitMax: false, // If false, max value increases automatically if value > maxValue
			limitMin: false, // If true, the min value of the gauge will be fixed
			colorStart: '#ff0000', // Colors
			colorStop: '#1f77b4', // just experiment with them
			OLD_colorStop: '#5bb3bdBF', // just experiment with them
			strokeColor: '#24243a', // to see which ones work best for you
			generateGradient: true,
			highDpiSupport: true, // High resolution support
		};

        var percentColors:Array<Dynamic> = [[0.0, "#448844"], [0.35, "#448844"], [0.36, "#ffbf00"], [0.45, "#ffbf00"], [0.46, "#ff4444"], [1.0, "#ff4444"]];
        opts.percentColors = percentColors;


		_gauge = new Gauge(_container).setOptions(opts); // create sexy gauge!
		_gauge.maxValue = 20000 / 1000; // set max gauge value
		_gauge.setMinValue(0); // Prefer setter over gauge.minValue = 0
		_gauge.animationSpeed = 16; // set animation speed (32 is default value)
		_gauge.set(_value); // set actual value
        _gauge.setTextField(_textfield);
	}

    private var _value:Float = 0;
    public function setValue(value:Float) {
        _value = value;
        if (_gauge != null) {
            _gauge.set(value);
        }
    }

	private override function validateComponentLayout():Bool {
		var b = super.validateComponentLayout();
		if (width > 0 && height > 0 && _container != null) {
			_container.style.width = HtmlUtils.px(width);
			_container.style.height = HtmlUtils.px(height);
			_container.width = Std.int(width);
			_container.height = Std.int(height);
            _gauge.update(true);
		}
		return b;
	}
}
