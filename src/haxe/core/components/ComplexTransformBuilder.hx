package core.components;

import haxe.ui.components.Button;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import core.data.DataSourceData;
import core.components.dialogs.transforms.TransformResultsPreviewDialog;
import haxe.ui.events.UIEvent;

using StringTools;

class ComplexTransformBuilder extends VBox {
    private var _transformContainer:VBox;

    public function new() {
        super();
        _transformContainer = new VBox();
        _transformContainer.percentWidth = 100;
        addComponent(_transformContainer);

        var testButton = new Button();
        testButton.text = "Preview Results";
        testButton.horizontalAlign = "right";
        testButton.onClick = onPreviewResults;
        addComponent(testButton);
    }

    private var _transformString:String = null;
    public var transformString(get, set):String;
    private function get_transformString():String {
        _transformString = "";
        var builders = findComponents(SimpleTransformBuilder);
        if (builders.length > 0) {
            var array = [];
            for (b in builders) {
                if (b.transformString != null) {
                    array.push(b.transformString);
                }
            }
            _transformString = array.join("->");
        }
        return _transformString;
    }
    private function set_transformString(value:String):String {
        _transformString = value;
        _transformContainer.removeAllComponents();
        if (_transformString == null) {
            addTransform();
        } else {
            var parts = _transformString.split("->");
            for (p in parts) {
                p = p.trim();
                if (p.length == 0) {
                    continue;
                }
                addTransform(p);
            }
        }
        return value;
    }

    private function onPreviewResults(_) {
        var dialog = new TransformResultsPreviewDialog();
        dialog.transformString = transformString;
        dialog.selectedDataSource = _selectedDataSource;
        dialog.show();
    }

    public function addTransform(transformString:String = null) {
        var hbox = new HBox();
        hbox.percentWidth = 100;

        var transform = new SimpleTransformBuilder();
        transform.selectedDataSource = _selectedDataSource;
        transform.transformString = transformString;
        transform.percentWidth = 100;
        transform.onChange = onTransformBuilderChange;
        hbox.addComponent(transform);

        var removeButton = new Button();
        removeButton.text = "-";
        hbox.addComponent(removeButton);

        var addButton = new Button();
        addButton.text = "+";
        addButton.onClick = function(_) {
            addTransform();
        }
        hbox.addComponent(addButton);

        _transformContainer.addComponent(hbox);
    }

    private function onTransformBuilderChange(_) {
        dispatch(new UIEvent(UIEvent.CHANGE));
    }

    private var _selectedDataSource:DataSourceData = null;
    public var selectedDataSource(get, set):DataSourceData;
    private function get_selectedDataSource():DataSourceData {
        return _selectedDataSource;
    }
    private function set_selectedDataSource(value:DataSourceData):DataSourceData {
        _selectedDataSource = value;
        var builders = findComponents(SimpleTransformBuilder);
        for (b in builders) {
            b.selectedDataSource = _selectedDataSource;
        }
        return value;
    }
}