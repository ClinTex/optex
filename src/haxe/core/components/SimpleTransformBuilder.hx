package core.components;

import haxe.ui.events.UIEvent;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import core.components.dialogs.transforms.TransformConfigDialog;
import haxe.ui.components.Button;
import core.components.portlets.PortletDataUtils;
import haxe.ui.components.DropDown;
import haxe.ui.containers.HBox;
import haxe.ui.containers.Box;
import haxe.ui.containers.dialogs.Dialog;
import core.data.DataSourceData;
import core.data.InternalDB;
import haxe.ui.data.ArrayDataSource;
import core.components.dialogs.transforms.GroupByTransformConfigDialog;
import core.components.dialogs.transforms.AverageTransformConfigDialog;

using StringTools;

class SimpleTransformBuilder extends Box {
    private var _simpleHBox:HBox;
    private var _functionSelector:DropDown;

    private var _transformParams:Array<String> = [];
    private var _configButton:Button;

    public function new() {
        super();
        _simpleHBox = new HBox();
        _simpleHBox.percentWidth = 100;
        addComponent(_simpleHBox);

        _functionSelector = new DropDown();
        _functionSelector.percentWidth = 100;
        _functionSelector.onChange = function(_) {
            if (_functionSelector.selectedItem == null) {
                return;
            }
            var transformId:String = _functionSelector.selectedItem.transformId;
            if (transformId == "none") {
                _configButton.hide();
            } else {
                _configButton.show();
            }
            buildTransformString();
        }
        _simpleHBox.addComponent(_functionSelector);

        _configButton = new Button();
        _configButton.width = 200;
        _configButton.text = "Configure";
        _configButton.onClick = onConfigButton;
        _configButton.hide();
        _simpleHBox.addComponent(_configButton);

    }

    private override function onReady() {
        super.onReady();
        refreshFunctionList();
    }

    private function onConfigButton(_) {
        var transformId:String = _functionSelector.selectedItem.transformId;
        if (transformId == "none") {
            return;
        }

        var dialog:TransformConfigDialog = null;
        switch (transformId) {
            case "group-by":
                dialog = new GroupByTransformConfigDialog();
            case "average":
                dialog = new AverageTransformConfigDialog();
        }

        if (dialog == null) {
            return;
        }

        dialog.selectedDataSource = _selectedDataSource;
        dialog.transformParams = _transformParams;
        dialog.onDialogClosed = function(e:DialogEvent) {
            if (e.button == DialogButton.APPLY) {
                _transformParams = dialog.transformParams;
                buildTransformString();
                _configButton.text = dialog.humanReadableTransformParams;
            }
        }
        dialog.show();
    }

    private var _transformString:String;
    public var transformString(get, set):String;
    private function get_transformString():String {
        return _transformString;
    }
    private function set_transformString(value:String):String {
        _transformString = value;
        if (_transformString != null) {
            var n1 = _transformString.indexOf("(");
            var n2 = _transformString.lastIndexOf(")");
            if (n1 > -1) {
                var temp = _transformString.substring(n1 + 1, n2);
                var parts = temp.split(",");
                var params = [];
                for (p in parts) {
                    p = p.trim();
                    if (p.length == 0) {
                        continue;
                    }
                    params.push(p);
                }
                _transformParams = params;
            }
        }
        return value;
    }

    private function buildTransformString() {
        if (_functionSelector.selectedItem == null) {
            return;
        }
        var transformId:String = _functionSelector.selectedItem.transformId;
        if (transformId == "none") {
            _transformString = null;
            return;
        }
        _transformString = transformId + "(" + _transformParams.join(", ") + ")";
        trace("current transform string: " + _transformString);
        dispatch(new UIEvent(UIEvent.CHANGE));
    }

    private var _selectedDataSource:DataSourceData = null;
    public var selectedDataSource(get, set):DataSourceData;
    private function get_selectedDataSource():DataSourceData {
        return _selectedDataSource;
    }
    private function set_selectedDataSource(value:DataSourceData):DataSourceData {
        _selectedDataSource = value;
        return value;
    }

    private function refreshFunctionList() {
        var transformList = [
            {text: "None", transformId: "none", originalText: "None"},
            {text: "Group By", transformId: "group-by", originalText: "Group By"},
            {text: "Average", transformId: "average", originalText: "Average"},
        ];

        var ds = new ArrayDataSource<Dynamic>();
        var indexToSelect = 0;
        var n = 0;
        for (item in transformList) {
            if (_transformString != null && _transformString.startsWith(item.transformId)) {
                indexToSelect = n;
            }
            ds.add(item);
            n++;
        }
        _functionSelector.dataSource = ds;
        _functionSelector.selectedIndex = indexToSelect;
    }
}