package;

import haxe.ui.Toolkit;
import haxe.ui.HaxeUIApp;

class Main {
    public static function main() {
        var app = new HaxeUIApp();
        Toolkit.theme = "optex";
        app.ready(function() {
            app.addComponent(new MainView());

            app.start();
        });
    }
}