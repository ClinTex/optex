package core.components.portlets;

import haxe.ui.components.Label;

class SiteMapPortletInstance extends PortletInstance {
    private override function onReady() {
        super.onReady();
        var button = new Label();
        button.percentWidth = 100;
        button.text = this.className;
        addComponent(button);
    }
}