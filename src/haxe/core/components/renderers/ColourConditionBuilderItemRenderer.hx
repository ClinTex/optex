package core.components.renderers;

import haxe.ui.core.ItemRenderer;
import haxe.ui.events.UIEvent;

@:xml('
<item-renderer width="100%" layoutName="horizontal">
    <style>
        .colour-condition-builder-item-renderer .textfield {
            border: none;
            filter: none;
            border-bottom: 1px solid $normal-border-color;            
            border-radius: 0;
            padding-left: 0;
            background-color: none;
        }
        
        .colour-condition-builder-item-renderer .textfield:active {
            border-bottom: 1px solid $accent-color;            
        }
    </style>
    <dropdown id="itemTypeSelector" width="110" verticalAlign="center">
        <data>
            <item text="Less Than" itemId="lt" />
            <item text="Between" itemId="btwn" />
            <item text="Greater Than" itemId="gt" />
        </data>
    </dropdown>
    <box width="100%" verticalAlign="bottom">
        <hbox width="100%" id="lessThanForm" verticalAlign="center" hidden="true">
            <textfield id="lessThanValue" width="100%" placeholder="value" style="text-align:center" />
        </hbox>
        <hbox width="100%" id="betweenForm" verticalAlign="center" hidden="true">
            <textfield id="betweenValue1" width="100%" placeholder="value" style="text-align:center" />
            <label text="and" verticalAlign="center" />
            <textfield id="betweenValue2" width="100%" placeholder="value" style="text-align:center" />
        </hbox>
        <hbox width="100%" id="greaterThanForm" verticalAlign="center" hidden="true">
            <textfield id="greaterThanValue" width="100%" placeholder="value" style="text-align:center" />
        </hbox>
    </box>
</item-renderer>
')
class ColourConditionBuilderItemRenderer extends ItemRenderer {
    @:clonable @:value(conditionData) public var value:Dynamic;
    
    public function new() {
        super();
    }
    
    private var _conditionData:String;
    public var conditionData(get, set):String;
    private function get_conditionData():String {
        return _conditionData;
    }
    private function set_conditionData(value:String):String {
        _conditionData = value;
        var parts = _conditionData.split(" ");
        var itemId = parts.shift();
        switch (itemId) {
            case "lt":
                if (parts[0] != null) {
                    lessThanValue.text = parts[0];
                }
                itemTypeSelector.selectedIndex = 0;
            case "btwn":
                if (parts[0] != null) {
                    betweenValue1.text = parts[0];
                }
                if (parts[1] != null) {
                    betweenValue2.text = parts[1];
                }
                itemTypeSelector.selectedIndex = 1;
            case "gt":
                if (parts[0] != null) {
                    greaterThanValue.text = parts[0];
                }
                itemTypeSelector.selectedIndex = 2;
        }
        return value;
    }
    
    @:bind(itemTypeSelector, UIEvent.CHANGE)
    private function onItemTypeChanged(event:UIEvent) {
        event.cancel();
        if (itemTypeSelector.selectedItem == null) {
            return;
        }
        switch (itemTypeSelector.selectedItem.itemId) {
            case "lt":
                lessThanForm.show();
                betweenForm.hide();
                greaterThanForm.hide();
                buildConditionString();
            case "btwn":
                lessThanForm.hide();
                betweenForm.show();
                greaterThanForm.hide();
                buildConditionString();
            case "gt":
                lessThanForm.hide();
                betweenForm.hide();
                greaterThanForm.show();
                buildConditionString();
        }
    }
    
    @:bind(lessThanValue, UIEvent.CHANGE)
    @:bind(betweenValue1, UIEvent.CHANGE)
    @:bind(betweenValue2, UIEvent.CHANGE)
    @:bind(greaterThanValue, UIEvent.CHANGE)
    private function onValueChange(event:UIEvent) {
        event.cancel();
        buildConditionString();
    }

    private function buildConditionString() {
        if (itemTypeSelector.selectedItem == null) {
            return;
        }
        
        var parts = null;
        switch (itemTypeSelector.selectedItem.itemId) {
            case "lt":
                parts = ["lt"];
                if (lessThanValue.text != null && lessThanValue.text != "") {
                    parts.push(lessThanValue.text);
                }
            case "btwn":
                parts = ["btwn"];
                if (betweenValue1.text != null && betweenValue1.text != "") {
                    parts.push(betweenValue1.text);
                }
                if (betweenValue2.text != null && betweenValue2.text != "") {
                    parts.push(betweenValue2.text);
                }
            case "gt":
                parts = ["gt"];
                if (greaterThanValue.text != null && greaterThanValue.text != "") {
                    parts.push(greaterThanValue.text);
                }
        }
        
        if (parts != null) {
            _conditionData = parts.join(" ");
            if (_data != null) {
                _data.condition = _conditionData;
            }
            trace("---> ", _data);
            var event = new UIEvent(UIEvent.CHANGE);
            dispatch(event);
            trace(_conditionData);
        }
    }
}