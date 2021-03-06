package;

import haxe.ui.util.Timer;
import haxe.ui.core.Screen;
import haxe.ui.containers.dialogs.Dialog.DialogEvent;
import dialogs.LoginDialog;
import haxe.ui.containers.Grid;
import dialogs.TransformBrowserDialog;
import components.WorkingIndicator;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.HorizontalSplitter;
import haxe.ui.containers.VerticalSplitter;
import haxe.ui.components.Spacer;
import haxe.ui.components.Label;
import haxe.ui.components.Link;
import haxe.ui.components.Image;
import core.dashboards.Portlet;
import haxe.ui.containers.HBox;
import haxe.ui.containers.Box;
import haxe.ui.containers.Card;
import haxe.ui.core.ComponentClassMap;
import views.DataView;
import haxe.ui.containers.menus.Menu.MenuEvent;
import haxe.ui.containers.VBox;
import core.data.DatabaseManager;
import core.components.portlets.PortletContainer;

//@:build(haxe.ui.ComponentBuilder.build("assets/main-view.xml"))
class MainView extends VBox {
    //public static var instance:MainView = null;

    public function new() {
        super();

        //instance = this;

        ComponentClassMap.instance.registerClassName("vbox", Type.getClassName(VBox));
        ComponentClassMap.instance.registerClassName("hbox", Type.getClassName(HBox));
        ComponentClassMap.instance.registerClassName("box", Type.getClassName(Box));
        ComponentClassMap.instance.registerClassName("portlet", Type.getClassName(Portlet));
        ComponentClassMap.instance.registerClassName("card", Type.getClassName(Card));
        ComponentClassMap.instance.registerClassName("image", Type.getClassName(Image));
        ComponentClassMap.instance.registerClassName("link", Type.getClassName(Link));
        ComponentClassMap.instance.registerClassName("label", Type.getClassName(Label));
        ComponentClassMap.instance.registerClassName("spacer", Type.getClassName(Spacer));
        ComponentClassMap.instance.registerClassName("vertical-splitter", Type.getClassName(VerticalSplitter));
        ComponentClassMap.instance.registerClassName("horizontal-splitter", Type.getClassName(HorizontalSplitter));
        ComponentClassMap.instance.registerClassName("vsplitter", Type.getClassName(VerticalSplitter));
        ComponentClassMap.instance.registerClassName("hsplitter", Type.getClassName(HorizontalSplitter));
        ComponentClassMap.instance.registerClassName("grid", Type.getClassName(Grid));
        ComponentClassMap.instance.registerClassName("portletcontainer", Type.getClassName(PortletContainer));

        //mainContent.hide();
    }
    
    public override function onReady() {
        super.onReady();
        var working = new WorkingIndicator();
        working.showWorking();
        DatabaseManager.instance.init().then(function(r) {
            trace("database manager ready");
            working.workComplete();
            showLogin();
        });
    }

    private function showLogin() {
        /*
        var dialog = new LoginDialog();
        dialog.onDialogClosed = function(e:DialogEvent) {
            if (e.button == "Login") {
                startLogin();
            }
        }
        dialog.show();
        */
        startLogin();
    }

    private var _workingLogin:WorkingIndicator;
    private function startLogin() {
        var fakeFail = false;
        _workingLogin = new WorkingIndicator();
        _workingLogin.showWorking();
        Timer.delay(function() {
            if (fakeFail == true) {
                _workingLogin.workComplete();
                _workingLogin = null;
                showLogin();
            } else {
                completeLogin();
            }
        }, 0);
    }

    private function completeLogin() {
        DatabaseManager.instance.start().then(function(r) {
            _workingLogin.workComplete();
            _workingLogin = null;
            Screen.instance.removeComponent(this);
            var adminView = new AdminView();
            Screen.instance.addComponent(adminView);
        });
    }

    /*
    @:bind(mainMenu, MenuEvent.MENU_SELECTED)
    private function onMenuMenu(e:MenuEvent) {
        switch (e.menuItem.id) {
            case "removeCurrentDatabase":
                DataView.instance.removeCurrentDatabase();
            case "clearAll":
                clearAllDbs();
            case "transformBrowser":
                var dialog = new TransformBrowserDialog();
                dialog.show();
        }
    }
    */

    private function clearAllDbs() {
        /*
        var working = new WorkingIndicator();
        working.showWorking();
        DatabaseManager.instance.removeDatabase("ClintexPrimaryData").then(function(r) {
            DatabaseManager.instance.removeDatabase("__optex_internal_data").then(function(r) {
                working.workComplete();
            });
            
        });
        */
    }

    /*
    @:bind(mainStack, UIEvent.CHANGE)
    private function onMainStackChanged(_) {
        mainButtons.selectedIndex = mainStack.selectedIndex;
    }

    public function changeView(id:String) {
        mainStack.selectedId = id;
    }
    */
}
