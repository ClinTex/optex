package core.components;

import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import core.components.dialogs.markers.MarkerConfigDialog;
import core.components.dialogs.markers.StaticYMarkerConfigDialog;
import haxe.ui.components.CheckBox;
import haxe.ui.components.Button;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.components.DropDown;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;

class MarkerFunctionSelector extends VBox {
    private var _functionSelector:DropDown;
    private var _behindCheckBox:CheckBox;

    private var _markerParams:Array<String> = null;    

    public function new() {
        super();

        var hbox:HBox = new HBox();
        hbox.percentWidth = 100;
        addComponent(hbox);

        _functionSelector = new DropDown();
        _functionSelector.percentWidth = 100;
        _functionSelector.onChange = function(_) {
            var event = new UIEvent(UIEvent.CHANGE);
            dispatch(event);
        }

        hbox.addComponent(_functionSelector);
        var ds = new ArrayDataSource<Dynamic>();
        ds.add({ text: "None", functionId: "none"});
        ds.add({ text: "Static Line (Y-Axis)", functionId: "static-y"});
        _functionSelector.dataSource = ds;

        var configButton = new Button();
        configButton.onClick = onConfig;
        configButton.text = "Configure";
        hbox.addComponent(configButton);

        _behindCheckBox = new CheckBox();
        _behindCheckBox.text = "Behind Graph";
        _behindCheckBox.onChange = function(_) {
            _markerBehind = _behindCheckBox.selected;
            var event = new UIEvent(UIEvent.CHANGE);
            dispatch(event);
        }
        addComponent(_behindCheckBox);
    }

    private var _markerBehind:Bool = false;
    public var markerBehind(get, set):Bool;
    private function get_markerBehind():Bool {
        return _markerBehind;
    }
    private function set_markerBehind(value:Bool):Bool {
        _markerBehind = value;
        return value;
    }

    private var _markerString:String = null;
    public var markerString(get, set):String;
    private function get_markerString():String {
        if (_functionSelector.selectedItem == null) {
            return _markerString;
        }
        var functionId:String = _functionSelector.selectedItem.functionId;
        if (functionId == null) {
            return _markerString;
        }

        if (functionId == "none") {
            return null;
        }

        if (_markerParams != null) {
            _markerString = functionId + "(" + _markerParams.join(", ") + ")";
        } else {
            _markerString = functionId;
        }
        return _markerString;
    }
    private function set_markerString(value:String):String {
        _markerString = value;
        return value;
    }

    private function onConfig(_) {
        var functionId:String = _functionSelector.selectedItem.functionId;
        var dialog:MarkerConfigDialog = null;
        switch (functionId) {
            case "static-y":
                dialog = new StaticYMarkerConfigDialog();
        }

        if (dialog != null) {
            dialog.onDialogClosed = function(e) {
                if (e.button == DialogButton.APPLY) {
                    _markerParams = dialog.markerParams;
                    var event = new UIEvent(UIEvent.CHANGE);
                    dispatch(event);
                }
            };
            dialog.show();
        }
    }
}