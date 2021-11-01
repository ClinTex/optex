package components;

import haxe.ui.util.Timer;
import haxe.ui.core.Screen;
import haxe.ui.core.Component;
import haxe.ui.containers.VBox;

@:build(haxe.ui.ComponentBuilder.build("assets/components/working-indicator.xml"))
class WorkingIndicator extends VBox {
    public function new() {
        super();
    }

    public var message(get, set):String;
    private function get_message():String {
        return messageLabel.text;
    }
    private function set_message(value:String):String {
        messageLabel.text = value;
        return value;
    }

    public function showWorking(message:String = null, target:Component = null) {
        if (message == null) {
            message = "Working, please wait...";
        }

        var targetCX = Screen.instance.width;
        var targetCY = Screen.instance.height;
        var cx = this.width;
        var cy = this.height;

        var xpos = (targetCX / 2) - (cx / 2);
        var ypos = (targetCY / 2) - (cy / 2);

        messageLabel.text = message;

        showOverlay();
        Screen.instance.addComponent(this);
        this.left = xpos;
        this.top = ypos;
    }

    public function workComplete(message:String = null, errored:Bool = false, autoClose:Bool = true, closeButtonText:String = null, closeCallback:Void->Void = null) {
        if (errored == true) {
            autoClose = false;
        }

        var icon = "icons/icons8-checked.gif";
        if (errored == true) {
            icon = "icons/icons8-error.gif";
        }

        if (message == null) {
            if (errored == false) {
                message = "Completed successfully";
            } else {
                message = "Completed unsuccessfully";
            }
        }

        if (closeButtonText == null) {
            closeButtonText = "Close";
        }

        messageLabel.text = message;
        statusImage.resource = icon;

        if (autoClose == true) {
            /*
            Timer.delay(function() {
                Screen.instance.removeComponent(this);
            }, 2000);
            */
            hideOverlay();
            Screen.instance.removeComponent(this);
            if (closeCallback != null) {
                closeCallback();
            }
        } else {
            closeButton.show();
            closeButton.onClick = function(_) {
                hideOverlay();
                Screen.instance.removeComponent(this);
                if (closeCallback != null) {
                    closeCallback();
                }
            }
        }
    }

    private var _overlay:Component = null;
    private function showOverlay() {
        _overlay = new Component();
        _overlay.id = "modal-background";
        _overlay.addClass("modal-background");
        _overlay.percentWidth = _overlay.percentHeight = 100;
        Screen.instance.addComponent(_overlay);
    } 

    private function hideOverlay() {
        Screen.instance.removeComponent(_overlay);
        _overlay = null;
    }
}
