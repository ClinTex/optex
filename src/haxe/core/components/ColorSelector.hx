package core.components;

import haxe.ui.components.DropDown;
import haxe.ui.containers.Box;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;
import haxe.ui.core.ItemRenderer;
import haxe.ui.events.MouseEvent;
import haxe.ui.events.UIEvent;
import haxe.ui.util.Color;

@:xml('
<dropdown type="color">
    <item-renderer width="100%" height="100%">
        <box width="100%" height="100%" style="padding: 2px;background-color: white; border: 1px solid $normal-border-color">
            <box id="selectedColorPreview" width="100%" height="100%" style="background-color: red">
                <label text="" />
            </box>
        </box>
    </item-renderer>
</dropdown>
')
class ColorSelector extends DropDown {
    public function new() {
        super();
        DropDownBuilder.HANDLER_MAP.set("color", Type.getClassName(ColorDropDownHandler));
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// HANDLER
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@:access(haxe.ui.core.Component)
class ColorDropDownHandler extends DropDownHandler {
    private var _view:ColorDropDownView = null;
    
    private override function get_component():Component {
        if (_view == null) {
            _view = new ColorDropDownView();
            _view.selectedColor = _cachedSelectedColor;
            _view.onChange = onColorChange;
        }
        
        return _view;
    }
    
    private var _cachedSelectedColor:Color = null;
    private override function get_selectedItem():Dynamic {
        if (_view != null) {
            _cachedSelectedColor = _view.selectedColor;
            return _view.selectedColor;
        }
        return _cachedSelectedColor;
    }
    
    private override function set_selectedItem(value:Dynamic):Dynamic {
        if ((value is String)) {
            _cachedSelectedColor = Std.string(value);
        } else {
            _cachedSelectedColor = value;
        }
        onColorChange(null);
        if (_view != null) {
            _view.selectedColor = _cachedSelectedColor;
        }
        return value;
    }
    
    private function onColorChange(e:UIEvent) {
        var itemRenderer = _dropdown.findComponent(ItemRenderer);
        if (itemRenderer != null) {
            var preview = itemRenderer.findComponent("selectedColorPreview", Box);
            if (preview != null) {
                if (e == null) {
                    if (_view != null) {
                        _view.selectedColor = _cachedSelectedColor;
                    }
                } else {
                    _cachedSelectedColor = _view.selectedColor;
                }
                preview.backgroundColor = _cachedSelectedColor;
                cast(_dropdown._internalEvents, DropDownEvents).hideDropDown();
                _dropdown.dispatch(new UIEvent(UIEvent.CHANGE));
                
                if (_view != null) {
                    for (items in _view.findComponents("palette-item", Box)) {
                        items.removeClass(":hover");
                    }
                }
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// VIEW
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@:xml('
<vbox style="padding: 5px;">
    <style>
        .palette-item-wrapper {
            border: 1px solid $normal-border-color;
            padding: 2px;
        }
        
        .palette-item {
            width: 16px;
            height: 16px;
            pointer-events: true;
        }
        
        .palette-item:hover {
            border: 2px solid #ef4810;
        }
        
        .palette-item:selected {
            border: 2px solid #ef4810;
        }
        
        .mainColumn {
            spacing: 0px;
            border: 1px solid $normal-border-color;
            padding: 2px;
        }
        
        .mainColumn .palette-item-wrapper {
            border: none;
            padding: none;
        }
    </style>
    
    <hbox id="topItems" />
    
    <spacer height="0" />
    
    <hbox id="mainItems">
        <vbox id="column0" styleName="mainColumn" />
        <vbox id="column1" styleName="mainColumn" />
        <vbox id="column2" styleName="mainColumn" />
        <vbox id="column3" styleName="mainColumn" />
        <vbox id="column4" styleName="mainColumn" />
        <vbox id="column5" styleName="mainColumn" />
        <vbox id="column6" styleName="mainColumn" />
        <vbox id="column7" styleName="mainColumn" />
        <vbox id="column8" styleName="mainColumn" />
        <vbox id="column9" styleName="mainColumn" />
    </hbox>
    
    <spacer height="0" />
    
    <hbox id="bottomItems" />
    
    <spacer height="0" />
    <rule width="100%" />
    <spacer height="0" />
    
    <vbox width="100%" style="padding-left: 5px; padding-right: 5px;">
        <grid width="100%" columns="4">
            <label text="Hex:" verticalAlign="center" style="font-size: 10px;" />
            <textfield id="hexField" width="65" style="font-size: 10px;text-align:center;" />
            
            <label text="RGB:" verticalAlign="center" style="font-size: 10px;" />
            <hbox width="100%">
                <textfield id="redField" width="100%" style="font-size: 10px;text-align:center;" />
                <textfield id="greenField" width="100%" style="font-size: 10px;text-align:center;" />
                <textfield id="blueField" width="100%" style="font-size: 10px;text-align:center;" />
            </hbox>
        </grid>
        <button id="applyButton" text="Apply" style="font-size: 10px;padding:4px 7px" horizontalAlign="right" />
    </vbox>    
    
    <spacer height="0" />
</vbox>
')
class ColorDropDownView extends VBox {
    public var topColors:Array<Color> = ["#ffffff", "#000000", "#e7e6e6", "#44546a", "#4472c4", "#ed7d31", "#a6a6a6", "#ffd000", "#5b9bd5", "#70ad47"];
    public var mainColors:Array<Color> = [
        "#f2f2f2", "#808080", "#d0cece", "#d6dce4", "#d9e2f3", "#fbe5d5", "#ededed", "#fff2cc", "#deebf6", "#e2efd9", 
        "#d8d8d8", "#595959", "#aeabab", "#adb9ca", "#b4c6e7", "#f7cbac", "#dbdbdb", "#fee599", "#bdd7ee", "#c5e0b3", 
        "#bfbfbf", "#3f3f3f", "#757070", "#8496b0", "#8eaadb", "#f4b183", "#c9c9c9", "#ffd965", "#9cc3e5", "#a8d08d", 
        "#a5a5a5", "#262626", "#3a3838", "#323f4f", "#2f5496", "#c55a11", "#7b7b7b", "#bf9000", "#2e75b5", "#538135", 
        "#7f7f7f", "#0c0c0c", "#171616", "#222a35", "#1f3864", "#833c0b", "#525252", "#7f6000", "#1e4e79", "#375623"
    ];
    public var bottomColors:Array<Color> = ["#c00000", "#ff0000", "#ffc000", "#ffff00", "#92d050", "#00b050", "#00b0f0", "#0070c0", "#002060", "#7030a0"];
    
    public function new() {
        super();
        buildColors();
    }
    
    private var _selectedColor:Null<Color> = null;
    public var selectedColor(get, set):Null<Color>;
    private function get_selectedColor():Null<Color> {
        return _selectedColor;
    }
    private function set_selectedColor(value:Null<Color>):Null<Color> {
        applySelectedColor(value);
        var event = new UIEvent(UIEvent.CHANGE);
        dispatch(event);
        return value;
    }
    
    private function applySelectedColor(value:Null<Color>) {
        _selectedColor = value;
        var selectedItem = null;
        for (item in findComponents("palette-item", Box)) {
            item.removeClass(":selected");
            if (item.backgroundColor == _selectedColor) {
                selectedItem = item;
            }
        }
        if (selectedItem != null) {
            selectedItem.addClass(":selected");
        }
        
        hexField.text = "#" + StringTools.hex(_selectedColor.toInt(), 6);
        redField.text = Std.string(_selectedColor.r);
        greenField.text = Std.string(_selectedColor.g);
        blueField.text = Std.string(_selectedColor.b);
    }
    
    private function buildColors() {
        for (col in topColors) {
            var c = buildColor(col);
            topItems.addComponent(c);
        }
        
        var n = 0;
        for (col in mainColors) {
            var c = buildColor(col);
            var column = mainItems.findComponent("column" + n, VBox);
            column.addComponent(c);
            n++;
            if (n >= 10) {
                n = 0;
            }
        }
        
        for (col in bottomColors) {
            var c = buildColor(col);
            bottomItems.addComponent(c);
        }
    }
    
    private function buildColor(color:Color):Box {
        var container = new Box();
        container.styleNames = "palette-item-wrapper";
        var item = new Box();
        item.styleNames = "palette-item";
        container.addComponent(item);
        item.backgroundColor = color;
        return container;
    }
    
    private override function onReady() {
        super.onReady();
        var items = findComponents("palette-item", Box);
        for (item in items) {
            item.onClick = onItemClicked;
            item.onMouseOver = onItemOver;
        }
    }
    
    private function onItemClicked(e:MouseEvent) {
        selectedColor = e.target.backgroundColor;
    }
    
    private function onItemOver(e:MouseEvent) {
        var currentColor:Color = e.target.backgroundColor;
        applyPreviewColor(currentColor);
    }
    
    private function applyPreviewColor(currentColor:Color) {
        hexField.text = "#" + StringTools.hex(currentColor.toInt(), 6);
        redField.text = Std.string(currentColor.r);
        greenField.text = Std.string(currentColor.g);
        blueField.text = Std.string(currentColor.b);
        
        var hoverItem = null;
        for (item in findComponents("palette-item", Box)) {
            item.removeClass(":hover");
            if (item.backgroundColor == currentColor) {
                hoverItem = item;
            }
        }
        if (hoverItem != null) {
            hoverItem.addClass(":hover");
        }
    }
    
    @:bind(hexField, UIEvent.CHANGE)
    private function onHexFieldChange(_) {
        var hex = hexField.text;
        if (StringTools.startsWith(hex, "#") == false) {
            return;
        }
        if (hex.length != 7) {
            return;
        }
        
        applyPreviewColor(hex);
    }
    
    @:bind(redField, UIEvent.CHANGE)
    @:bind(greenField, UIEvent.CHANGE)
    @:bind(blueField, UIEvent.CHANGE)
    private function onColorComponentChange(_) {
        var r = StringTools.hex(Std.parseInt(redField.text), 2);
        var g = StringTools.hex(Std.parseInt(greenField.text), 2);
        var b = StringTools.hex(Std.parseInt(blueField.text), 2);
        var hex = "#" + r + g + b;
        hexField.text = hex;
        applyPreviewColor(hex);
    }
    
    @:bind(applyButton, MouseEvent.CLICK)
    private function onApplyColor(_) {
        var hex = hexField.text;
        if (StringTools.startsWith(hex, "#") == false) {
            return;
        }
        if (hex.length != 7) {
            return;
        }
        
        selectedColor = hex;
    }
}