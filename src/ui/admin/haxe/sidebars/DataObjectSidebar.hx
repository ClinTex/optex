package sidebars;

import haxe.ui.events.MouseEvent;
import components.WorkingIndicator;
import haxe.ui.components.Button;
import haxe.ui.containers.SideBar;

class DataObjectSidebar extends SideBar {
    public override function onReady() {
        super.onReady();
        var cancelButton = findComponent("cancelButton", Button);
        if (cancelButton != null) {
            cancelButton.onClick = onCancel;
        }
        var createButton = findComponent("createButton", Button);
        if (createButton != null) {
            createButton.onClick = onCreate;
        }
    }

    private var _create:Bool = false;
    private function onCancel(e:MouseEvent) {
        _create = false;
        hide();
    }

    private var _working:WorkingIndicator;
    private function onCreate(e:MouseEvent) {
        _create = true;
        hide();
    }

    private override function onHideAnimationEnd() {
        super.onHideAnimationEnd();
        if (_create == true) {
            _working = new WorkingIndicator();
            _working.showWorking();
            createObject();
        }
    }

    private function createComplete() {
        _working.workComplete();
    }

    private function createObject() {

    }

}