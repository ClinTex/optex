package core.components.portlets;

import haxe.ui.components.Button;

class StaticImagePortletInstance extends PortletInstance {
    private override function onReady() {
        super.onReady();
        var button = new Button();
        button.text = this.className;
        addComponent(button);
    }
}