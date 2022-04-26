package core.components.portlets;

import haxe.Json;
import haxe.ui.containers.dialogs.Dialog.DialogButton;
import haxe.ui.components.Button;
import haxe.ui.containers.HBox;
import haxe.ui.containers.Box;
import haxe.ui.components.Image;
import haxe.ui.events.MouseEvent;
import core.components.dialogs.GenericPortletConfigDialog;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import core.data.PortletInstancePortletData;
import core.data.PortletInstanceLayoutData;

class PortletContainer extends Box {
    private var _portletContent:Box;

    private var _controls:HBox;

    public function new() {
        super();
        _portletContent = new Box();
        _portletContent.percentWidth = _portletContent.percentHeight = 100;
        _portletContent.id = "portletContent";
        addComponent(_portletContent);

        _controls = new HBox();
        _controls.hide();
        var button = new Button();
        button.text = "Remove";
        button.onClick = onRemovePortletInstance;
        _controls.addComponent(button);
        var button = new Button();
        button.text = "Configure";
        button.onClick = onConfigurePortletInstance;
        _controls.addComponent(button);
        _controls.horizontalAlign = "right";
        _controls.opacity = .5;
        _controls.hide();
        addComponent(_controls);

        onMouseOver = function(_) {
            if (_editable) {
                _controls.show();
            }
        }
        onMouseOut = function(_) {
            if (_editable) {
                _controls.hide();
            }
        }

        _controls.onMouseOver = function(_) {
            _controls.opacity = 1;
        }

        _controls.onMouseOut = function(_) {
            _controls.opacity = .5;
        }
    }

    private function onRemovePortletInstance(_) {
        this.portletInstance = null;
    }

    private function onConfigurePortletInstance(_) {
        var dialog = new GenericPortletConfigDialog();
        dialog.addConfigPage(_portletInstance.configPage);
        var prettyJson = Json.stringify(portletInstance.instanceData.data, null, "  ");
        dialog.portletConfigJsonField.text = prettyJson;
        dialog.onDialogClosed = function(event:DialogEvent) {
            if (event.button == DialogButton.APPLY) {
                if (_portletInstance != null) {
                    var json = Json.parse(dialog.portletConfigJsonField.text);
                    for (f in Reflect.fields(json)) {
                        var v = Reflect.field(json, f);
                        Reflect.setField(portletInstance.instanceData.data, f, v);
                    }

                    page.preloadPortletInstance(_portletInstance).then(function(r) {
                        _portletInstance.initPortlet();
                        _portletInstance.refreshView();
                    });
                }
            }
        }
        dialog.show();
    }

    private var _portletInstance:PortletInstance = null;
    public var portletInstance(get, set):PortletInstance;
    private function get_portletInstance():PortletInstance {
        return _portletInstance;
    }
    private function set_portletInstance(value:PortletInstance):PortletInstance {
        _portletInstance = value;

        _portletContent.removeAllComponents();
        if (_portletInstance != null) {
            if (_portletInstance.instanceData == null) {
                _portletInstance.instanceData = new PortletInstancePortletData();
            }
            _portletInstance.instanceData.portletClassName = _portletInstance.className;
    
            if (_portletInstance.layoutData == null) {
                _portletInstance.layoutData = new PortletInstanceLayoutData();
            }
            _portletInstance.layoutData.portletContainerId = this.id;
    
            _portletInstance.percentWidth = 100;
            _portletInstance.percentHeight = 100;
            _portletContent.addComponent(_portletInstance);
            _portletInstance.initPortlet();
            _portletInstance.refreshView();
            if (_editable) {
                //_controls.show();
            }
        } else {
            if (_editable) {
                addPortletAssignUI();
                //_controls.hide();
            }
        }
        return value;
    }

    private var _editable:Bool = false;
    public var editable(get, set):Bool;
    private function get_editable():Bool {
        return _editable;
    }
    private function set_editable(value:Bool):Bool {
        _editable = value;
        applyEditable();
        return value;
    }

    private function applyEditable() {
        if (_editable) {
            addClass("editable");
            if (_portletInstance == null) {
                addPortletAssignUI();
            }
        } else {
            removeClass("editable");
            if (_portletInstance == null) {
                _portletContent.removeAllComponents();
            }
        }
    }

    private function addPortletAssignUI() {
        _portletContent.removeAllComponents();
        var image = new Image();
        image.resource = "icons/icons8-plus-+-32.png";
        image.verticalAlign = "center";
        image.horizontalAlign = "center";
        image.userData = this.id;
        image.styleString = "cursor:pointer;";
        image.onClick = onAddImageClick;
        _portletContent.addComponent(image);
    }

    private function onAddImageClick(event:MouseEvent) {
        var portletEvent = new PortletEvent(PortletEvent.ASSIGN_PORTLET_CLICKED);
        portletEvent.portletContainer = this;
        dispatch(portletEvent);
    }

    public var page(get, null):Page;
    private function get_page():Page {
        var p = findAncestor(Page);
        return p;
    }
}